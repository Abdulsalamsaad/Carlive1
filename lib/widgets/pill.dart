import 'package:flutter/material.dart';
import '../constants.dart';

class Pill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const Pill({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? cNavy : cCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? cNavy : cLine),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : cText,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
