import 'package:flutter/material.dart';

enum SnackType { success, error, warning, info }

void showAppSnackBar(
  BuildContext context, {
  required String message,
  SnackType type = SnackType.success,
}) {
  Color bgColor;
  IconData icon;

  switch (type) {
    case SnackType.success:
      bgColor = Colors.green.shade600;
      icon = Icons.check_circle_outline_rounded;
      break;

    case SnackType.error:
      bgColor = Colors.red.shade600;
      icon = Icons.error_outline_rounded;
      break;

    case SnackType.warning:
      bgColor = Colors.amber.shade700;
      icon = Icons.warning_amber_rounded;
      break;

    case SnackType.info:
      bgColor = Colors.blue.shade600;
      icon = Icons.info_outline_rounded;

    default:
      bgColor = Colors.grey.shade800;
      icon = Icons.notifications_none;
  }

  final snackBar = SnackBar(
    elevation: 10,
    backgroundColor: Colors.transparent,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
    animation: CurvedAnimation(
      parent: AnimationController(
        vsync: ScaffoldMessenger.of(context),
        duration: const Duration(milliseconds: 300),
      ),
      curve: Curves.easeOutBack,
    ),
    content: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
