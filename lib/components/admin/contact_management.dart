import 'package:flutter/material.dart';
import '../../utils/auth_utils.dart';
import '../../services/api_service.dart';
import '../../utils/date_formatter.dart';
import 'dart:developer' as developer;
import 'contact_status_update_dialog.dart';

class ContactManagement extends StatefulWidget {
  const ContactManagement({Key? key}) : super(key: key);

  @override
  _ContactManagementState createState() => _ContactManagementState();
}

class _ContactManagementState extends State<ContactManagement> {
  List<dynamic> _contacts = [];
  bool _loadingContacts = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  String _getStatusFrench(String? status) {
    if (status == null) return 'N/A';
    
    switch (status) {
      case 'open':
        return 'Ouvert';
      case 'processing':
        return 'En cours de traitement';
      case 'closed':
        return 'Fermé';
      case 'rejected':
        return 'Rejeté';
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status) {
      case 'open':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'closed':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showStatusUpdateDialog(dynamic contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ContactStatusUpdateDialog(
          contact: contact,
          onStatusUpdated: _fetchContacts,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Gestion des contacts",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _fetchContacts,
                icon: Icon(_loadingContacts ? Icons.hourglass_empty : Icons.refresh),
                label: Text(_loadingContacts ? "Chargement..." : "Actualiser"),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _loadingContacts
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.contact_mail_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text("Aucun contact trouvé", style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _fetchContacts,
                              child: const Text("Essayer à nouveau"),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          final statusFrench = _getStatusFrench(contact['status']);
                          final statusColor = _getStatusColor(contact['status']);
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  contact['firstName'] != null ? contact['firstName'][0].toUpperCase() : 'C',
                                  style: TextStyle(color: Colors.blue.shade800),
                                ),
                              ),
                              title: Text(
                                '${contact['firstName']} ${contact['lastName']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(contact['email'] ?? 'Email non disponible'),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          contact['subject'] ?? 'Pas de sujet',
                                          style: TextStyle(color: Colors.grey.shade600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: statusColor.withOpacity(0.5)),
                                        ),
                                        child: Text(
                                          statusFrench,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow('ID', contact['id']?.toString() ?? 'N/A'),
                                      _buildDetailRow('Prénom', contact['firstName'] ?? 'N/A'),
                                      _buildDetailRow('Nom', contact['lastName'] ?? 'N/A'),
                                      _buildDetailRow('Email', contact['email'] ?? 'N/A'),
                                      _buildDetailRow('Sujet', contact['subject'] ?? 'N/A'),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              'Statut:',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              statusFrench,
                                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit, size: 20),
                                            onPressed: () => _showStatusUpdateDialog(contact),
                                            tooltip: "Modifier le statut",
                                            color: Colors.blue,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Message:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(contact['message'] ?? 'Pas de message'),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDetailRow(
                                        'Soumis le',
                                        DateFormatter.formatDateTime(contact['submittedAt']),
                                      ),
                                      if (contact['createdAt'] != null)
                                        _buildDetailRow(
                                          'Créé le',
                                          DateFormatter.formatDateTime(contact['createdAt']),
                                        ),
                                      if (contact['updatedAt'] != null)
                                        _buildDetailRow(
                                          'Mis à jour le',
                                          DateFormatter.formatDateTime(contact['updatedAt']),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueColor != null ? TextStyle(color: valueColor, fontWeight: FontWeight.bold) : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchContacts() async {
    setState(() {
      _loadingContacts = true;
    });

    try {
      final token = await AuthUtils.getToken();
      
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur d'authentification"), backgroundColor: Colors.red),
        );
        setState(() {
          _loadingContacts = false;
        });
        return;
      }

      final response = await ApiService().request(
        method: 'GET',
        endpoint: '/contacts',
        withAuth: true,
      );

      if (response.data is List) {
        setState(() {
          _contacts = response.data;
          _loadingContacts = false;
        });
      } else if (response.data is Map<String, dynamic>) {
        final possibleListKeys = ['data', 'contacts', 'results', 'items', 'content'];
        
        for (final key in possibleListKeys) {
          if (response.data.containsKey(key) && response.data[key] is List) {
            setState(() {
              _contacts = response.data[key];
              _loadingContacts = false;
            });
            return;
          }
        }
        
        developer.log('Réponse reçue mais pas au format attendu: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Format de réponse inattendu de l'API"),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _contacts = [];
          _loadingContacts = false;
        });
      }
    } catch (error) {
      developer.log('Erreur lors de la récupération des contacts: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $error"), backgroundColor: Colors.red),
      );
      setState(() {
        _contacts = [];
        _loadingContacts = false;
      });
    }
  }
}
