import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class HotspotInfoCardWidget extends StatelessWidget {
  final Map<String, dynamic> hotspot;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const HotspotInfoCardWidget({
    super.key,
    required this.hotspot,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(hotspot["status"] as String),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getStatusTitle(hotspot["status"] as String),
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.getNeutralColor(true),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Point potential and distance
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: 'stars',
                    label: 'Points',
                    value: '${hotspot["pointPotential"]}',
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    icon: 'location_on',
                    label: 'Distance',
                    value: hotspot["distance"] as String,
                    color: AppTheme.getAccentColor(true),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Recent activity
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'history',
                    color: AppTheme.getNeutralColor(true),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hotspot["recentActivity"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Trash types (if any)
            if ((hotspot["trashTypes"] as List).isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Common Trash Types:',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (hotspot["trashTypes"] as List).map((type) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      type.toString().replaceAll('_', ' '),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onNavigate,
                    icon: CustomIconWidget(
                      iconName: 'directions',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 18,
                    ),
                    label: Text('Directions'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/ar-camera-cleanup');
                    },
                    icon: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 18,
                    ),
                    label: Text('Start Cleanup'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: color,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'high':
        return AppTheme.lightTheme.colorScheme.error;
      case 'moderate':
        return AppTheme.getWarningColor(true);
      case 'clean':
        return AppTheme.getSuccessColor(true);
      default:
        return AppTheme.getNeutralColor(true);
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'high':
        return 'High Priority Cleanup';
      case 'moderate':
        return 'Moderate Cleanup Needed';
      case 'clean':
        return 'Recently Cleaned Area';
      default:
        return 'Cleanup Location';
    }
  }
}
