import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Badge penanda lamaran prioritas / impian
class PriorityBadge extends StatelessWidget {
  final bool isCompact;

  const PriorityBadge({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.priority.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.star_rounded, size: 16, color: AppTheme.priority),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.priority.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.priority.withOpacity(0.4)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: AppTheme.priority),
          SizedBox(width: 4),
          Text(
            'Prioritas Impian',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.priority,
            ),
          ),
        ],
      ),
    );
  }
}

