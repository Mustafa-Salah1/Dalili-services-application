import 'package:flutter/material.dart';

class ProviderAvailabilityCard extends StatelessWidget {
  final bool busy;
  final String? customerName;
  final int remainingMinutes;

  const ProviderAvailabilityCard({
    super.key,
    required this.busy,
    this.customerName,
    required this.remainingMinutes,
  });

  @override
  Widget build(BuildContext context) {
    if (!busy) {
      return Card(
        color: Colors.green.shade50,
        child: const ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text('Available'),
          subtitle: Text('Ready for new requests'),
        ),
      );
    }

    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: const Icon(Icons.access_time, color: Colors.red),
        title: Text('Busy with $customerName'),
        subtitle: Text('$remainingMinutes minutes remaining'),
      ),
    );
  }
}
