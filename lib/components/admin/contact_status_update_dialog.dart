import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ContactStatusUpdateDialog extends StatefulWidget {
  final dynamic contact;
  final Function onStatusUpdated;

  const ContactStatusUpdateDialog({
    Key? key,
    required this.contact,
    required this.onStatusUpdated,
  }) : super(key: key);

  @override
  _ContactStatusUpdateDialogState createState() => _ContactStatusUpdateDialogState();
}

class _ContactStatusUpdateDialogState extends State<ContactStatusUpdateDialog> {
  bool _updatingStatus = false;
  String selectedStatus = '';

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.contact['status'] ?? 'open';
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

  Future<void> _updateContactStatus() async {
    setState(() {
      _updatingStatus = true;
    });

    try {
      final contactId = widget.contact['id'].toString();
      final response = await ApiService().request(
        method: 'PATCH',
        endpoint: '/contacts/$contactId/status',
        withAuth: true,
        body: {
          "status": selectedStatus
        },
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Statut mis à jour avec succès"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
          widget.onStatusUpdated();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur lors de la mise à jour du statut: ${response.error}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      developer.log('Erreur lors de la mise à jour du statut: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingStatus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          minWidth: 300,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Modifier le statut",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Contact: ${widget.contact['firstName']} ${widget.contact['lastName']}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                const Text("Sélectionnez un nouveau statut:"),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatusOption('open'),
                      const Divider(height: 1),
                      _buildStatusOption('processing'),
                      const Divider(height: 1),
                      _buildStatusOption('closed'),
                      const Divider(height: 1),
                      _buildStatusOption('rejected'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Annuler"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _updatingStatus ? null : _updateContactStatus,
                      child: _updatingStatus
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text("Mettre à jour"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(String status) {
    final isSelected = selectedStatus == status;
    final statusText = _getStatusFrench(status);
    
    Color getStatusColor() {
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

    return InkWell(
      onTap: () {
        setState(() {
          selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: isSelected ? getStatusColor().withOpacity(0.1) : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? getStatusColor() : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: getStatusColor(),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
} 