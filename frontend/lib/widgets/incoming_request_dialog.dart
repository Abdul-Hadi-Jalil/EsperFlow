import 'package:esperflow/models/blood_request.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown to a donor when a blood request push arrives — the in-app half of
/// "the request is visible to all users".
class IncomingRequestDialog extends StatelessWidget {
  final BloodRequest request;

  const IncomingRequestDialog({super.key, required this.request});

  Future<void> _call(BuildContext context) async {
    final number = request.phoneNumber;
    if (number == null || number.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri) && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the dialer')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCall = (request.phoneNumber ?? '').isNotEmpty;

    return AlertDialog(
      icon: const Icon(Icons.bloodtype, color: Color(0xFFE31A1A), size: 36),
      title: Text(
        request.isUrgent
            ? 'Urgent: ${request.bloodGroup} blood needed'
            : '${request.bloodGroup} blood needed',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(icon: Icons.person, label: request.fullName),
          if (request.location.isNotEmpty)
            _DetailRow(icon: Icons.location_on, label: request.location),
          if (canCall)
            _DetailRow(icon: Icons.phone, label: request.phoneNumber!),
          if (request.isUrgent)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'This request is marked urgent.',
                style: TextStyle(
                  color: Color(0xFFE31A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if ((request.note ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                request.note!,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Dismiss'),
        ),
        if (canCall)
          ElevatedButton.icon(
            onPressed: () => _call(context),
            icon: const Icon(Icons.phone, size: 18),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31A1A),
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
