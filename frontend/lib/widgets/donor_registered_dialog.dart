import 'package:esperflow/services/donor_service.dart';
import 'package:flutter/material.dart';

/// Confirmation shown after registering as a donor.
class DonorRegisteredDialog extends StatelessWidget {
  final DonorRegistration registration;
  final String bloodGroup;

  const DonorRegisteredDialog({
    super.key,
    required this.registration,
    required this.bloodGroup,
  });

  @override
  Widget build(BuildContext context) {
    final reachable = registration.canReceiveRequests;

    return AlertDialog(
      icon: Icon(
        reachable ? Icons.check_circle : Icons.notifications_off,
        color: reachable ? Colors.green : Colors.orange,
        size: 40,
      ),
      title: Text(
        registration.updatedExisting
            ? 'Registration updated'
            : 'You are registered',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bloodtype, color: Color(0xFFE31A1A)),
                const SizedBox(width: 8),
                Text(
                  bloodGroup,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFE31A1A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (reachable)
            const Text(
              'You will get a notification whenever someone requests blood.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            )
          else
            const Text(
              'Notifications are turned off, so you will not be alerted about '
              'blood requests. Enable notifications for EsperFlow in your '
              'phone settings, then submit this form again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.orange),
            ),
          if (registration.updatedExisting)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Your existing registration on this device was updated.',
                textAlign: TextAlign.center,
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
