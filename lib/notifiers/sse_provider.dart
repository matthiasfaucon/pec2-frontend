import 'package:flutter/material.dart';
import 'package:firstflutterapp/interfaces/comment.dart';
import 'package:firstflutterapp/services/sse_service.dart';

class SSEProvider extends ChangeNotifier {
  // Map qui garde les services SSE en cours par postId
  final Map<String, SSEService> _sseServices = {};
  // Map qui stocke l'état de connexion pour chaque post
  final Map<String, bool> _connectionStatus = {};
  // Map qui stocke les commentaires par postId
  final Map<String, List<Comment>> _commentsByPostId = {};

  // Getter pour vérifier si un post a une connexion SSE active
  bool isConnected(String postId) {
    return _connectionStatus[postId] ?? false;
  }
  
  // Getter pour récupérer tous les commentaires d'un post
  List<Comment> getComments(String postId) {
    return _commentsByPostId[postId] ?? [];
  }

  // Initialise une connexion SSE pour un post spécifique
  void connectToSSE(String postId) {
    debugPrint('SSEProvider: Tentative de connexion SSE pour le post $postId');
    
    // Si on a déjà une connexion pour ce post, on ne fait rien
    if (_sseServices.containsKey(postId)) {
      debugPrint('SSEProvider: Connexion SSE déjà active pour le post $postId');
      return;
    }

    // Crée un nouveau service SSE
    final sseService = SSEService(
      postId: postId,
      onNewComment: (comment) {
        debugPrint('SSEProvider: Nouveau commentaire reçu via SSE: ${comment.id}');
        _addComment(postId, comment);
        notifyListeners();
      },
      onExistingComments: (comments) {
        debugPrint('SSEProvider: ${comments.length} commentaires existants reçus via SSE');
        _addComments(postId, comments);
        notifyListeners();
      },
      onConnectionStatusChanged: (isConnected) {
        _connectionStatus[postId] = isConnected;
        debugPrint('SSEProvider: État de connexion SSE pour post $postId: ${isConnected ? "connecté" : "déconnecté"}');
        notifyListeners();
      },
    );

    // Stocke le service et tente de se connecter
    _sseServices[postId] = sseService;
    sseService.connect().then((_) {
      debugPrint('SSEProvider: Connexion SSE établie avec succès pour le post $postId');
    }).catchError((error) {
      debugPrint('SSEProvider: Erreur de connexion SSE pour post $postId: $error');
      _connectionStatus[postId] = false;
      notifyListeners();
    });
  }

  // Ajoute un nouveau commentaire à la liste pour un post
  void _addComment(String postId, Comment comment) {
    debugPrint('SSEProvider: Ajout du commentaire ${comment.id} au post $postId');
    
    if (!_commentsByPostId.containsKey(postId)) {
      _commentsByPostId[postId] = [];
    }
    
    // Vérifie si le commentaire existe déjà
    bool commentExists = _commentsByPostId[postId]!.any((c) => c.id == comment.id);
    if (commentExists) {
      debugPrint('SSEProvider: Commentaire ${comment.id} déjà présent, pas d\'ajout');
      return;
    }
    
    _commentsByPostId[postId]!.add(comment);
    
    // Tri des commentaires par date (plus récent en dernier)
    _commentsByPostId[postId]!.sort((a, b) {
      final dateA = DateTime.parse(a.createdAt);
      final dateB = DateTime.parse(b.createdAt);
      return dateA.compareTo(dateB);
    });
    
    debugPrint('SSEProvider: Commentaire ${comment.id} ajouté avec succès');
  }

  // Ajoute plusieurs commentaires à la liste pour un post
  void _addComments(String postId, List<Comment> comments) {
    debugPrint('SSEProvider: Ajout de ${comments.length} commentaires au post $postId');
    
    if (!_commentsByPostId.containsKey(postId)) {
      _commentsByPostId[postId] = [];
    }
    
    final List<Comment> existingComments = _commentsByPostId[postId]!;
    int addedCount = 0;
    
    // Ajoute seulement les commentaires qui n'existent pas déjà
    for (final comment in comments) {
      if (!existingComments.any((c) => c.id == comment.id)) {
        existingComments.add(comment);
        addedCount++;
      }
    }
    
    if (addedCount > 0) {
      // Tri des commentaires par date (plus récent en dernier)
      _commentsByPostId[postId]!.sort((a, b) {
        final dateA = DateTime.parse(a.createdAt);
        final dateB = DateTime.parse(b.createdAt);
        return dateA.compareTo(dateB);
      });
      
      debugPrint('SSEProvider: $addedCount nouveaux commentaires ajoutés sur ${comments.length}');
    } else {
      debugPrint('SSEProvider: Aucun nouveau commentaire ajouté (tous déjà existants)');
    }
  }

  // Envoie un nouveau commentaire
  Future<Comment?> sendComment(String postId, String content) async {
    try {
      debugPrint('SSEProvider: Envoi d\'un commentaire pour le post $postId');
      final comment = await SSEService.sendComment(postId, content);
      debugPrint('SSEProvider: Commentaire envoyé avec succès: ${comment.id}');
      
      // Vérifie si ce commentaire existe déjà dans notre liste locale
      final commentsList = _commentsByPostId[postId] ?? [];
      final commentExists = commentsList.any((c) => c.id == comment.id);
      
      if (!commentExists) {
        debugPrint('SSEProvider: Ajout du commentaire à la liste locale');
        // Ajout manuel du commentaire à notre liste locale
        _addComment(postId, comment);
        notifyListeners();
      } else {
        debugPrint('SSEProvider: Commentaire déjà présent dans la liste locale');
      }
      
      return comment;
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de l\'envoi du commentaire: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Déconnecte tous les services SSE
  void disconnectAll() {
    for (final service in _sseServices.values) {
      service.disconnect();
    }
    _sseServices.clear();
    _connectionStatus.clear();
    notifyListeners();
  }

  // Déconnecte une connexion SSE spécifique
  void disconnect(String postId) {
    final service = _sseServices[postId];
    if (service != null) {
      service.disconnect();
      _sseServices.remove(postId);
      _connectionStatus[postId] = false;
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    disconnectAll();
    super.dispose();
  }
}
