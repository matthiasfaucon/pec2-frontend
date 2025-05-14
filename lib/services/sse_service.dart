// File: lib/services/sse_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:firstflutterapp/interfaces/comment.dart';
import 'package:firstflutterapp/utils/auth_utils.dart';
import 'package:firstflutterapp/utils/platform_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html' as html;

class SSEService {
  final String postId;
  final Function(Comment) onNewComment;
  final Function(List<Comment>) onExistingComments;
  final Function(bool) onConnectionStatusChanged;

  StreamSubscription? _subscription;
  EventSourceBase? _eventSource;
  bool _isConnected = false;

  SSEService({
    required this.postId,
    required this.onNewComment,
    required this.onExistingComments,
    required this.onConnectionStatusChanged,
  });

  Future<void> connect() async {
    final token = await AuthUtils.getToken();
    if (token == null) {
      throw Exception('Utilisateur non connecté');
    }    
    final baseUrl = PlatformUtils.getApiBaseUrl();
    
    try {
      final sseUrl = '${baseUrl}/posts/$postId/comments/sse?token=$token';
      debugPrint('Connecting to SSE: $sseUrl');
      
      _eventSource = EventSourceFactory.create(sseUrl);
      _isConnected = true;
      onConnectionStatusChanged(true);
      
      _subscription = _eventSource!.events.listen(
        (event) {
          if (event.type == 'connected') {
            debugPrint('SSE Connected successfully');
          } else if (event.type == 'comment') {
            final dynamic data = jsonDecode(event.data!);
            
            if (data['type'] == 'new_comment') {
              final comment = Comment.fromJson(data['payload']);
              onNewComment(comment);
            } else if (data['type'] == 'existing_comment') {
              final comment = Comment.fromJson(data['payload']);
              onExistingComments([comment]);
            }
          }
        },
        onDone: () {
          _isConnected = false;
          onConnectionStatusChanged(false);
          debugPrint('SSE connection closed');
        },
        onError: (error) {
          _isConnected = false;
          onConnectionStatusChanged(false);
          debugPrint('SSE Error: $error');
        },
      );
    } catch (e) {
      _isConnected = false;
      onConnectionStatusChanged(false);
      debugPrint('Failed to connect to SSE: $e');
      rethrow;
    }
  }

  Future<void> sendComment(String content) async {
    if (!_isConnected) {
      throw Exception('Not connected to SSE');
    }

    final token = await AuthUtils.getToken();
    if (token == null) {
      throw Exception('Utilisateur non connecté');
    }

    final baseUrl = PlatformUtils.getApiBaseUrl();
    final commentUrl = '${baseUrl}/posts/$postId/comments?token=$token';

    try {
      final response = await http.post(
        Uri.parse(commentUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send comment: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending comment: $e');
      rethrow;
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _eventSource?.close();
    _isConnected = false;
    onConnectionStatusChanged(false);
  }
}

// Factory to create the appropriate EventSource implementation
class EventSourceFactory {
  static EventSourceBase create(String url) {
    if (kIsWeb) {
      return WebEventSource(url);
    } else {
      return IoEventSource(url);
    }
  }
}

// Base class for EventSource implementations
abstract class EventSourceBase {
  Stream<SSEEvent> get events;
  void close();
}

// Web implementation using the browser's native EventSource API
class WebEventSource implements EventSourceBase {
  final String url;
  final StreamController<SSEEvent> _streamController = StreamController<SSEEvent>.broadcast();
  html.EventSource? _eventSource;
  
  WebEventSource(this.url) {
    try {
      if (kIsWeb) {
        _eventSource = html.EventSource(url);
        
        _eventSource!.onOpen.listen((event) {
          _streamController.add(SSEEvent(type: 'connected'));
        });
        
        _eventSource!.onMessage.listen((event) {
          _streamController.add(SSEEvent(
            type: 'comment',
            data: event.data,
          ));
        });
        
        _eventSource!.onError.listen((event) {
          // EventSource automatically tries to reconnect
          debugPrint('Web SSE Error');
          // If the EventSource is closed (readyState == 2), emit an error
          if (_eventSource!.readyState == 2) {
            _streamController.addError('Connection closed by server');
          }
        });
        
        // Listen for custom event types
        _eventSource!.addEventListener('comment', (event) {
          final messageEvent = event as html.MessageEvent;
          _streamController.add(SSEEvent(
            type: 'comment',
            data: messageEvent.data as String,
          ));
        });
      } else {
        // For non-web platforms, immediately notify of connection
        _streamController.add(SSEEvent(type: 'connected'));
        // Then delegate to IoEventSource implementation
        final ioSource = IoEventSource(url);
        ioSource.events.listen(
          (event) => _streamController.add(event),
          onError: (error) => _streamController.addError(error),
          onDone: () {
            if (!_streamController.isClosed) {
              _streamController.close();
            }
          },
        );
      }
    } catch (e) {
      _streamController.addError(e);
    }
  }
  
  @override
  Stream<SSEEvent> get events => _streamController.stream;
  
  @override
  void close() {
    if (kIsWeb && _eventSource != null) {
      _eventSource!.close();
    }
    if (!_streamController.isClosed) {
      _streamController.close();
    }
  }
}

// Non-web implementation using http package
class IoEventSource implements EventSourceBase {
  final String url;
  final StreamController<SSEEvent> _streamController = StreamController<SSEEvent>.broadcast();
  http.Client? _client;
  bool _isClosed = false;

  IoEventSource(this.url) {
    _connect();
  }

  @override
  Stream<SSEEvent> get events => _streamController.stream;

  Future<void> _connect() async {
    if (_isClosed) return;

    _client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';
      
      final response = await _client!.send(request);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to connect to SSE: ${response.statusCode}');
      }
      
      // Add connected event
      _streamController.add(SSEEvent(type: 'connected'));
      
      // Process SSE stream
      response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_onData, onDone: _onDone, onError: _onError, cancelOnError: false);
    } catch (e) {
      _onError(e);
    }
  }

  // Current event being built
  String _eventType = 'message';
  String? _eventId;
  StringBuffer _eventData = StringBuffer();
  bool _inEvent = false;

  void _onData(String line) {
    if (_isClosed) return;
    
    // Empty line means end of an event
    if (line.isEmpty) {
      if (_inEvent) {
        _streamController.add(SSEEvent(
          id: _eventId,
          type: _eventType,
          data: _eventData.toString(),
        ));
        
        // Reset for next event
        _eventType = 'message';
        _eventId = null;
        _eventData = StringBuffer();
        _inEvent = false;
      }
      return;
    }
    
    _inEvent = true;
    
    // Parse the SSE line format: "field: value"
    if (line.startsWith('event:')) {
      _eventType = line.substring(6).trim();
    } else if (line.startsWith('id:')) {
      _eventId = line.substring(3).trim();
    } else if (line.startsWith('data:')) {
      // For data, we might get multiple data lines for one event
      if (_eventData.isNotEmpty) {
        _eventData.write('\n');
      }
      _eventData.write(line.substring(5).trim());
    } else if (line == ':keepalive') {
      // Server sent a keep-alive comment
      debugPrint('Received keepalive');
    }
  }

  void _onDone() {
    if (!_isClosed) {
      // Process any pending event
      if (_inEvent) {
        _streamController.add(SSEEvent(
          id: _eventId,
          type: _eventType,
          data: _eventData.toString(),
        ));
      }
      
      // Try to reconnect
      _client?.close();
      _client = null;
      
      // Attempt to reconnect after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isClosed) _connect();
      });
    }
  }

  void _onError(dynamic error) {
    debugPrint('SSE Error: $error');
    // Don't close on error, attempt to reconnect
    _client?.close();
    _client = null;
    
    // Attempt to reconnect after a delay
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isClosed) _connect();
    });
  }

  @override
  void close() {
    _isClosed = true;
    _client?.close();
    _client = null;
    if (!_streamController.isClosed) {
      _streamController.close();
    }
  }
}

class SSEEvent {
  final String? id;
  final String type;
  final String? data;
  
  SSEEvent({
    this.id,
    required this.type,
    this.data,
  });
  
  factory SSEEvent.fromMap(Map<String, String> map) {
    return SSEEvent(
      id: map['id'],
      type: map['event'] ?? 'message',
      data: map['data'],
    );
  }
}