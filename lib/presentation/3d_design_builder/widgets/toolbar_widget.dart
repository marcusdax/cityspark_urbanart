import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class ToolbarWidget extends StatelessWidget {
  final bool canUndo;
  final bool canRedo;
  final bool isPaletteVisible;
  final String currentTool;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onTogglePalette;
  final Function(String) onToolChanged;
  final VoidCallback onTemplateLibrary;
  final VoidCallback onSave;
  final VoidCallback onExport;

  const ToolbarWidget({
    super.key,
    required this.canUndo,
    required this.canRedo,
    required this.isPaletteVisible,
    required this.currentTool,
    required this.onUndo,
    required this.onRedo,
    required this.onTogglePalette,
    required this.onToolChanged,
    required this.onTemplateLibrary,
    required this.onSave,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Back',
          ),

          const SizedBox(width: 8),

          // Undo button
          IconButton(
            onPressed: canUndo ? onUndo : null,
            icon: CustomIconWidget(
              iconName: 'undo',
              color: canUndo
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.getNeutralColor(true),
              size: 24,
            ),
            tooltip: 'Undo',
          ),

          // Redo button
          IconButton(
            onPressed: canRedo ? onRedo : null,
            icon: CustomIconWidget(
              iconName: 'redo',
              color: canRedo
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.getNeutralColor(true),
              size: 24,
            ),
            tooltip: 'Redo',
          ),

          const SizedBox(width: 8),

          // Tool selection
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToolButton(
                  icon: 'add_box',
                  tool: 'place',
                  tooltip: 'Place Block',
                ),
                _buildToolButton(
                  icon: 'delete',
                  tool: 'delete',
                  tooltip: 'Delete Block',
                ),
                _buildToolButton(
                  icon: 'pan_tool',
                  tool: 'select',
                  tooltip: 'Select Block',
                ),
              ],
            ),
          ),

          const Spacer(),

          // Palette toggle
          IconButton(
            onPressed: onTogglePalette,
            icon: CustomIconWidget(
              iconName: isPaletteVisible ? 'palette' : 'palette_outlined',
              color: isPaletteVisible
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.getNeutralColor(true),
              size: 24,
            ),
            tooltip: isPaletteVisible ? 'Hide Palette' : 'Show Palette',
          ),

          // Template library
          IconButton(
            onPressed: onTemplateLibrary,
            icon: CustomIconWidget(
              iconName: 'library_books',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            tooltip: 'Template Library',
          ),

          const SizedBox(width: 8),

          // Save button
          ElevatedButton.icon(
            onPressed: onSave,
            icon: CustomIconWidget(
              iconName: 'save',
              color: Colors.white,
              size: 18,
            ),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
          ),

          const SizedBox(width: 8),

          // Export button
          OutlinedButton.icon(
            onPressed: onExport,
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: AppTheme.lightTheme.primaryColor,
              size: 18,
            ),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required String icon,
    required String tool,
    required String tooltip,
  }) {
    final isSelected = currentTool == tool;

    return GestureDetector(
      onTap: () => onToolChanged(tool),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: isSelected
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.getNeutralColor(true),
          size: 20,
        ),
      ),
    );
  }
}
