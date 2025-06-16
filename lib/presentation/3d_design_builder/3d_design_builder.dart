import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import './widgets/block_palette_widget.dart';
import './widgets/save_dialog_widget.dart';
import './widgets/template_library_widget.dart';
import './widgets/toolbar_widget.dart';
import './widgets/viewport_3d_widget.dart';

class ThreeDDesignBuilder extends StatefulWidget {
  const ThreeDDesignBuilder({super.key});

  @override
  State<ThreeDDesignBuilder> createState() => _ThreeDDesignBuilderState();
}

class _ThreeDDesignBuilderState extends State<ThreeDDesignBuilder>
    with TickerProviderStateMixin {
  // Mock data for blocks and templates
  final List<Map<String, dynamic>> blockTypes = [
    {
      "id": 1,
      "name": "Stone",
      "color": Color(0xFF808080),
      "texture":
          "https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=100&h=100&fit=crop",
      "isSelected": true,
    },
    {
      "id": 2,
      "name": "Wood",
      "color": Color(0xFF8B4513),
      "texture":
          "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=100&h=100&fit=crop",
      "isSelected": false,
    },
    {
      "id": 3,
      "name": "Glass",
      "color": Color(0xFF87CEEB),
      "texture":
          "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=100&h=100&fit=crop",
      "isSelected": false,
    },
    {
      "id": 4,
      "name": "Brick",
      "color": Color(0xFFB22222),
      "texture":
          "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=100&h=100&fit=crop",
      "isSelected": false,
    },
    {
      "id": 5,
      "name": "Metal",
      "color": Color(0xFFC0C0C0),
      "texture":
          "https://images.unsplash.com/photo-1567789884554-0b844b597180?w=100&h=100&fit=crop",
      "isSelected": false,
    },
  ];

  final List<Map<String, dynamic>> templates = [
    {
      "id": 1,
      "name": "Park Bench",
      "thumbnail":
          "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=150&h=150&fit=crop",
      "description": "Classic wooden park bench design",
      "blocks": 12,
    },
    {
      "id": 2,
      "name": "Flower Planter",
      "thumbnail":
          "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=150&h=150&fit=crop",
      "description": "Decorative planter for community gardens",
      "blocks": 8,
    },
    {
      "id": 3,
      "name": "Art Installation",
      "thumbnail":
          "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=150&h=150&fit=crop",
      "description": "Modern abstract sculpture",
      "blocks": 24,
    },
    {
      "id": 4,
      "name": "Bus Stop Shelter",
      "thumbnail":
          "https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=150&h=150&fit=crop",
      "description": "Functional bus stop with seating",
      "blocks": 36,
    },
  ];

  final List<Map<String, dynamic>> placedBlocks = [];
  final List<List<Map<String, dynamic>>> undoHistory = [];
  int selectedBlockIndex = 0;
  bool isPaletteVisible = true;
  bool isTemplateLibraryVisible = false;
  bool isBuildMode = true;
  bool isPlacementMode = false;
  String currentTool = 'place';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main 3D Viewport
            Positioned.fill(
              child: Viewport3DWidget(
                placedBlocks: placedBlocks,
                selectedBlock: blockTypes[selectedBlockIndex],
                isBuildMode: isBuildMode,
                isPlacementMode: isPlacementMode,
                onBlockPlaced: _onBlockPlaced,
                onBlockSelected: _onBlockSelected,
                onModeChanged: _onModeChanged,
              ),
            ),

            // Top Toolbar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ToolbarWidget(
                canUndo: undoHistory.isNotEmpty,
                canRedo: false,
                isPaletteVisible: isPaletteVisible,
                currentTool: currentTool,
                onUndo: _onUndo,
                onRedo: _onRedo,
                onTogglePalette: _onTogglePalette,
                onToolChanged: _onToolChanged,
                onTemplateLibrary: _onToggleTemplateLibrary,
                onSave: _onSave,
                onExport: _onExport,
              ),
            ),

            // Bottom Block Palette
            if (isPaletteVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BlockPaletteWidget(
                  blocks: blockTypes,
                  selectedIndex: selectedBlockIndex,
                  onBlockSelected: _onBlockTypeSelected,
                ),
              ),

            // Template Library Overlay
            if (isTemplateLibraryVisible)
              Positioned.fill(
                child: TemplateLibraryWidget(
                  templates: templates,
                  onTemplateSelected: _onTemplateSelected,
                  onClose: _onCloseTemplateLibrary,
                ),
              ),

            // Build Mode Indicator
            if (isBuildMode)
              Positioned(
                top: 80,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'build',
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Build Mode',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Placement Ghost Preview Indicator
            if (isPlacementMode)
              Positioned(
                top: 120,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.getAccentColor(true).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'touch_app',
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to Place',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Block Count Display
            Positioned(
              top: 80,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.cardColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Blocks Used',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.getNeutralColor(true),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${placedBlocks.length}',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBlockPlaced(Map<String, dynamic> blockData) {
    setState(() {
      // Save current state to undo history
      undoHistory.add(List.from(placedBlocks));

      // Add new block
      placedBlocks.add({
        ...blockData,
        'id': DateTime.now().millisecondsSinceEpoch,
        'type': blockTypes[selectedBlockIndex]['name'],
        'color': blockTypes[selectedBlockIndex]['color'],
        'texture': blockTypes[selectedBlockIndex]['texture'],
      });

      isPlacementMode = false;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _onBlockSelected(Map<String, dynamic> blockData) {
    // Show context menu for selected block
    _showBlockContextMenu(blockData);
  }

  void _onModeChanged(bool buildMode) {
    setState(() {
      isBuildMode = buildMode;
      if (!buildMode) {
        isPlacementMode = false;
      }
    });
  }

  void _onBlockTypeSelected(int index) {
    setState(() {
      selectedBlockIndex = index;
      // Update selection in block types
      for (int i = 0; i < blockTypes.length; i++) {
        blockTypes[i]['isSelected'] = i == index;
      }
      isPlacementMode = true;
    });

    HapticFeedback.selectionClick();
  }

  void _onUndo() {
    if (undoHistory.isNotEmpty) {
      setState(() {
        placedBlocks.clear();
        placedBlocks.addAll(undoHistory.removeLast());
      });
      HapticFeedback.lightImpact();
    }
  }

  void _onRedo() {
    // Redo functionality would be implemented with a separate redo stack
    HapticFeedback.lightImpact();
  }

  void _onTogglePalette() {
    setState(() {
      isPaletteVisible = !isPaletteVisible;
    });
  }

  void _onToolChanged(String tool) {
    setState(() {
      currentTool = tool;
      isPlacementMode = tool == 'place';
    });
  }

  void _onToggleTemplateLibrary() {
    setState(() {
      isTemplateLibraryVisible = !isTemplateLibraryVisible;
    });
  }

  void _onCloseTemplateLibrary() {
    setState(() {
      isTemplateLibraryVisible = false;
    });
  }

  void _onTemplateSelected(Map<String, dynamic> template) {
    // Load template blocks into the scene
    setState(() {
      undoHistory.add(List.from(placedBlocks));

      // Add template blocks (mock implementation)
      for (int i = 0; i < (template['blocks'] as int); i++) {
        placedBlocks.add({
          'id': DateTime.now().millisecondsSinceEpoch + i,
          'type': 'Stone',
          'color': Color(0xFF808080),
          'texture': blockTypes[0]['texture'],
          'x': (i % 4).toDouble(),
          'y': 0.0,
          'z': (i ~/ 4).toDouble(),
        });
      }

      isTemplateLibraryVisible = false;
    });

    HapticFeedback.mediumImpact();
  }

  void _onSave() {
    _showSaveDialog();
  }

  void _onExport() {
    _showExportDialog();
  }

  void _showBlockContextMenu(Map<String, dynamic> blockData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Block Options',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildContextMenuItem(
                  icon: 'delete',
                  label: 'Delete',
                  color: AppTheme.lightTheme.colorScheme.error,
                  onTap: () {
                    Navigator.pop(context);
                    _deleteBlock(blockData);
                  },
                ),
                _buildContextMenuItem(
                  icon: 'swap_horiz',
                  label: 'Replace',
                  color: AppTheme.lightTheme.primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    _replaceBlock(blockData);
                  },
                ),
                _buildContextMenuItem(
                  icon: 'content_copy',
                  label: 'Copy',
                  color: AppTheme.getAccentColor(true),
                  onTap: () {
                    Navigator.pop(context);
                    _copyBlock(blockData);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBlock(Map<String, dynamic> blockData) {
    setState(() {
      undoHistory.add(List.from(placedBlocks));
      placedBlocks.removeWhere((block) => block['id'] == blockData['id']);
    });
    HapticFeedback.mediumImpact();
  }

  void _replaceBlock(Map<String, dynamic> blockData) {
    setState(() {
      undoHistory.add(List.from(placedBlocks));
      final index =
          placedBlocks.indexWhere((block) => block['id'] == blockData['id']);
      if (index != -1) {
        placedBlocks[index] = {
          ...placedBlocks[index],
          'type': blockTypes[selectedBlockIndex]['name'],
          'color': blockTypes[selectedBlockIndex]['color'],
          'texture': blockTypes[selectedBlockIndex]['texture'],
        };
      }
    });
    HapticFeedback.lightImpact();
  }

  void _copyBlock(Map<String, dynamic> blockData) {
    setState(() {
      undoHistory.add(List.from(placedBlocks));
      placedBlocks.add({
        ...blockData,
        'id': DateTime.now().millisecondsSinceEpoch,
        'x': (blockData['x'] as double) + 1,
      });
    });
    HapticFeedback.lightImpact();
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => SaveDialogWidget(
        onSave: (String name, String description) {
          // Save design with name and description
          Navigator.pop(context);
          _saveDesign(name, description);
        },
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Export Design',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose export format for your 3D design:',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _exportAsPNG();
                    },
                    icon: CustomIconWidget(
                      iconName: 'image',
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text('PNG Image'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _exportAsOBJ();
                    },
                    icon: CustomIconWidget(
                      iconName: 'view_in_ar',
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text('3D Model'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveDesign(String name, String description) {
    // Mock save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Design "$name" saved successfully!'),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportAsPNG() {
    // Mock PNG export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Design exported as PNG to gallery'),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportAsOBJ() {
    // Mock OBJ export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('3D model exported as OBJ file'),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
