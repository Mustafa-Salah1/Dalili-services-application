import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
        ),

        borderRadius: BorderRadius.circular(size * 0.3),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.30),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Icon(
        Icons.home_repair_service,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}
