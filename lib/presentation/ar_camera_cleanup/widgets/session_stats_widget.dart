import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class SessionStatsWidget extends StatelessWidget {
  final String sessionTime;
  final double pointMultiplier;

  const SessionStatsWidget({
    super.key,
    required this.sessionTime,
    required this.pointMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Session timer
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'timer',
                color: AppTheme.lightTheme.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                sessionTime,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Point multiplier
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'trending_up',
                color: pointMultiplier > 1.0
                    ? AppTheme.getSuccessColor(true)
                    : AppTheme.lightTheme.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${pointMultiplier.toStringAsFixed(1)}x',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: pointMultiplier > 1.0
                      ? AppTheme.getSuccessColor(true)
                      : AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
