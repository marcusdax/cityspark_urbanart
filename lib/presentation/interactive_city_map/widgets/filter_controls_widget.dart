import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterControlsWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const FilterControlsWidget({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<FilterControlsWidget> createState() => _FilterControlsWidgetState();
}

class _FilterControlsWidgetState extends State<FilterControlsWidget> {
  double _distanceRadius = 2.0;
  int _minPoints = 50;
  Set<String> _selectedStatuses = {'high', 'moderate', 'clean'};
  final Set<String> _selectedTrashTypes = {};

  final List<String> _statusOptions = ['high', 'moderate', 'clean'];
  final List<String> _trashTypeOptions = [
    'bottles',
    'cans',
    'paper',
    'plastic',
    'food_waste',
    'cigarettes'
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Hotspots',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text('Reset'),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Distance radius slider
            Text(
              'Distance Radius: ${_distanceRadius.toStringAsFixed(1)} km',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Slider(
              value: _distanceRadius,
              min: 0.5,
              max: 5.0,
              divisions: 18,
              onChanged: (value) {
                setState(() {
                  _distanceRadius = value;
                });
                _notifyFilterChange();
              },
            ),

            SizedBox(height: 16),

            // Minimum points slider
            Text(
              'Minimum Points: $_minPoints',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Slider(
              value: _minPoints.toDouble(),
              min: 0,
              max: 200,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  _minPoints = value.round();
                });
                _notifyFilterChange();
              },
            ),

            SizedBox(height: 16),

            // Status filter
            Text(
              'Hotspot Status',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _statusOptions.map((status) {
                final isSelected = _selectedStatuses.contains(status);
                return FilterChip(
                  label: Text(_getStatusLabel(status)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedStatuses.add(status)
                          : _selectedStatuses.remove(status);
                    });
                    _notifyFilterChange();
                  },
                  selectedColor: _getStatusColor(status).withValues(alpha: 0.2),
                  checkmarkColor: _getStatusColor(status),
                  side: BorderSide(
                    color: isSelected
                        ? _getStatusColor(status)
                        : AppTheme.lightTheme.colorScheme.outline,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 16),

            // Trash type filter
            Text(
              'Trash Types',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _trashTypeOptions.map((type) {
                final isSelected = _selectedTrashTypes.contains(type);
                return FilterChip(
                  label: Text(type.replaceAll('_', ' ')),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedTrashTypes.add(type)
                          : _selectedTrashTypes.remove(type);
                    });
                    _notifyFilterChange();
                  },
                  selectedColor: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _distanceRadius = 2.0;
      _minPoints = 50;
      _selectedStatuses = {'high', 'moderate', 'clean'};
      _selectedTrashTypes.clear();
    });
    _notifyFilterChange();
  }

  void _notifyFilterChange() {
    widget.onFilterChanged({
      'distanceRadius': _distanceRadius,
      'minPoints': _minPoints,
      'statuses': _selectedStatuses.toList(),
      'trashTypes': _selectedTrashTypes.toList(),
    });
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'high':
        return 'High Priority';
      case 'moderate':
        return 'Moderate';
      case 'clean':
        return 'Clean';
      default:
        return status;
    }
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
}
