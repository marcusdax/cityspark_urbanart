import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class MapHotspotMarkerWidget extends StatelessWidget {
  final Map<String, dynamic> hotspot;
  final bool isSelected;
  final VoidCallback onTap;
  final Color markerColor;

  const MapHotspotMarkerWidget({
    super.key,
    required this.hotspot,
    required this.isSelected,
    required this.onTap,
    required this.markerColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 60 : 40,
        height: isSelected ? 60 : 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring for selected state
            if (isSelected)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: markerColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: markerColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),

            // Main marker
            Container(
              width: isSelected ? 40 : 32,
              height: isSelected ? 40 : 32,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getStatusIcon(hotspot["status"] as String),
                  color: AppTheme.lightTheme.colorScheme.surface,
                  size: isSelected ? 20 : 16,
                ),
              ),
            ),

            // Point potential badge
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${hotspot["pointPotential"]}',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'high':
        return 'warning';
      case 'moderate':
        return 'info';
      case 'clean':
        return 'check_circle';
      default:
        return 'location_on';
    }
  }
}
