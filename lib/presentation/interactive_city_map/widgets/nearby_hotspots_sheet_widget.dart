import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class NearbyHotspotsSheetWidget extends StatelessWidget {
  final List<Map<String, dynamic>> hotspots;
  final Function(String) onHotspotSelected;
  final VoidCallback onClose;

  const NearbyHotspotsSheetWidget({
    super.key,
    required this.hotspots,
    required this.onHotspotSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.getNeutralColor(true).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Hotspots',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.getNeutralColor(true),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Hotspots list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: hotspots.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final hotspot = hotspots[index];
                return _buildHotspotListItem(context, hotspot);
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildHotspotListItem(
      BuildContext context, Map<String, dynamic> hotspot) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _getStatusColor(hotspot["status"] as String),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.surface,
            width: 2,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: _getStatusIcon(hotspot["status"] as String),
            color: AppTheme.lightTheme.colorScheme.surface,
            size: 20,
          ),
        ),
      ),
      title: Text(
        _getStatusTitle(hotspot["status"] as String),
        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'stars',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                '${hotspot["pointPotential"]} points',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 12),
              CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.getAccentColor(true),
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                hotspot["distance"] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.getAccentColor(true),
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            hotspot["recentActivity"] as String,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.getNeutralColor(true),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              // Handle directions
            },
            icon: CustomIconWidget(
              iconName: 'directions',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            tooltip: 'Get Directions',
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/ar-camera-cleanup');
            },
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: AppTheme.getSuccessColor(true),
              size: 20,
            ),
            tooltip: 'Start Cleanup',
          ),
        ],
      ),
      onTap: () => onHotspotSelected(hotspot["id"] as String),
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

  String _getStatusTitle(String status) {
    switch (status) {
      case 'high':
        return 'High Priority Area';
      case 'moderate':
        return 'Moderate Cleanup';
      case 'clean':
        return 'Recently Cleaned';
      default:
        return 'Cleanup Location';
    }
  }
}
