import 'package:flutter/material.dart';

class InventoryStatusChip extends StatelessWidget {
  const InventoryStatusChip._({
    required this.label,
    required this.icon,
    required this.color,
  });

  const InventoryStatusChip.ok({super.key})
      : label = 'OK',
        icon = Icons.check_circle,
        color = const Color(0xFF18D6C8);

  const InventoryStatusChip.lowStock({super.key})
      : label = 'Stock bajo',
        icon = Icons.warning_amber_rounded,
        color = const Color(0xFFFFB84D);

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color.withOpacity(0.14),
      side: BorderSide(color: color.withOpacity(0.28)),
      avatar: Icon(
        icon,
        size: 18,
        color: color,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
