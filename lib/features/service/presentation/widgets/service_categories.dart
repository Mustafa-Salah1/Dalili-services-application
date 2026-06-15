import 'package:flutter/material.dart';

class ServiceCategories extends StatelessWidget {
  const ServiceCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.electrical_services, 'title': 'Electrician'},
      {'icon': Icons.plumbing, 'title': 'Plumber'},
      {'icon': Icons.format_paint, 'title': 'Painter'},
      {'icon': Icons.car_repair, 'title': 'Mechanic'},
    ];

    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];

          return Container(
            width: 90,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: const Color(0xFF0F766E),
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  category['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
