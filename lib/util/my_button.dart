import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final bool isPrimary;

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isPrimary
        ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B))
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    final defaultTextColor = isPrimary
        ? (isDark ? const Color(0xFF0F172A) : Colors.white)
        : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A));

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? defaultBg,
        foregroundColor: textColor ?? defaultTextColor,
        elevation: isPrimary ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor ?? defaultTextColor,
        ),
      ),
    );
  }
}