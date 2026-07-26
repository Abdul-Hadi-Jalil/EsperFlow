import 'package:esperflow/models/blood_request.dart';
import 'package:flutter/material.dart';

/// Confirmation shown to the requester: how many registered users the request
/// actually reached.
class RequestSentDialog extends StatelessWidget {
  final BroadcastResult result;

  const RequestSentDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final reached = result.notifiedCount;
    final nobodyReached = reached == 0;

    return AlertDialog(
      icon: Icon(
        nobodyReached ? Icons.info_outline : Icons.check_circle,
        color: nobodyReached ? Colors.orange : Colors.green,
        size: 40,
      ),
      title: Text(
        nobodyReached ? 'Request saved' : 'Request sent',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!nobodyReached) ...[
            Text(
              '$reached',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE31A1A),
              ),
            ),
            Text(
              reached == 1
                  ? 'registered user notified'
                  : 'registered users notified',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            if (result.compatibleDonorCount > 0)
              _StatChip(
                icon: Icons.bloodtype,
                label:
                    '${result.compatibleDonorCount} '
                    '${result.compatibleDonorCount == 1 ? 'donor has' : 'donors have'} '
                    'a compatible blood group',
              ),
            if (result.failedCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${result.failedCount} device(s) could not be reached.',
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Donors who can help will see your details and can call you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ] else
            Text(
              result.message.isNotEmpty
                  ? result.message
                  : 'Your request was saved, but no registered user has '
                        'notifications enabled yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          if (result.alreadyNotified)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'This request had already been broadcast.',
                style: TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE31A1A),
            foregroundColor: Colors.white,
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFE31A1A)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
