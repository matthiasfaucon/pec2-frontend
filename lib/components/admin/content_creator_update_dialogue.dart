import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ContentCreatorUpdateDialog extends StatefulWidget {
  final dynamic contentCreator;
  final Function onStatusUpdated;

  const ContentCreatorUpdateDialog({
    Key? key,
    required this.contentCreator,
    required this.onStatusUpdated,
  }) : super(key: key);

  @override
  _ContentCreatorUpdateDialogState createState() =>
      _ContentCreatorUpdateDialogState();
}

class _ContentCreatorUpdateDialogState
    extends State<ContentCreatorUpdateDialog> {
  bool _updatingStatus = false;
  String selectedStatus = '';

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.contentCreator['status'] ?? 'PENDING';
  }

  String _getStatusFrench(String? status) {
    if (status == null) return 'N/A';

    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'APPROVED':
        return 'Approuvé';
      case 'REJECTED':
        return 'Rejeté';
      default:
        return status;
    }
  }

  Future<void> _updateContentCreatorStatus() async {
    setState(() {
      _updatingStatus = true;
    });

    try {
      final contentCreatorId = widget.contentCreator['id'].toString();
      final response = await ApiService().request(
        method: 'PUT',
        endpoint: '/content-creators/$contentCreatorId/status',
        withAuth: true,
        body: {"status": selectedStatus},
      );

      if (response.statusCode == 200) {
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
        throw Exception('Erreur lors de la mise à jour du statut');
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, minWidth: 300),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Modifier le statut",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  "Entreprise: ${widget.contentCreator['companyName']}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  "SIRET: ${widget.contentCreator['siretNumber']}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
                      _buildStatusOption('PENDING'),
                      const Divider(height: 1),
                      _buildStatusOption('APPROVED'),
                      const Divider(height: 1),
                      _buildStatusOption('REJECTED'),
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
                      onPressed:
                          _updatingStatus ? null : _updateContentCreatorStatus,
                      child:
                          _updatingStatus
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
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
      switch (status.toUpperCase()) {
        case 'PENDING':
          return Colors.orange;
        case 'APPROVED':
          return Colors.green;
        case 'REJECTED':
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
            Icon(_getStatusIcon(status), color: getStatusColor(), size: 20),
            const SizedBox(width: 12),
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
              Icon(Icons.check_circle, color: getStatusColor(), size: 20),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
