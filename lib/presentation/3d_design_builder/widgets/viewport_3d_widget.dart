import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_export.dart';

class Viewport3DWidget extends StatefulWidget {
  final List<Map<String, dynamic>> placedBlocks;
  final Map<String, dynamic> selectedBlock;
  final bool isBuildMode;
  final bool isPlacementMode;
  final Function(Map<String, dynamic>) onBlockPlaced;
  final Function(Map<String, dynamic>) onBlockSelected;
  final Function(bool) onModeChanged;

  const Viewport3DWidget({
    super.key,
    required this.placedBlocks,
    required this.selectedBlock,
    required this.isBuildMode,
    required this.isPlacementMode,
    required this.onBlockPlaced,
    required this.onBlockSelected,
    required this.onModeChanged,
  });

  @override
  State<Viewport3DWidget> createState() => _Viewport3DWidgetState();
}

class _Viewport3DWidgetState extends State<Viewport3DWidget> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  Offset? _ghostBlockPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onLongPress: _onLongPress,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      onPanUpdate: _onPanUpdate,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.colorScheme.surface,
              AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 3D Scene Background Grid
            _build3DGrid(),

            // 3D Scene Transform Container
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(_offset.dx, _offset.dy)
                ..scale(_scale)
                ..rotateX(_rotationX)
                ..rotateY(_rotationY),
              child: Stack(
                children: [
                  // Placed blocks
                  ..._buildPlacedBlocks(),

                  // Ghost block preview
                  if (widget.isPlacementMode && _ghostBlockPosition != null)
                    _buildGhostBlock(),
                ],
              ),
            ),

            // Mode toggle button
            Positioned(
              bottom: 140,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _toggleMode,
                backgroundColor: widget.isBuildMode
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.getNeutralColor(true),
                child: CustomIconWidget(
                  iconName: widget.isBuildMode ? 'build' : 'pan_tool',
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            // Reset view button
            Positioned(
              bottom: 200,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _resetView,
                backgroundColor: AppTheme.lightTheme.cardColor,
                child: CustomIconWidget(
                  iconName: 'center_focus_strong',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
              ),
            ),

            // Instructions overlay
            if (widget.placedBlocks.isEmpty) _buildInstructionsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _build3DGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(
        gridColor: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
        gridSize: 40.0,
      ),
    );
  }

  List<Widget> _buildPlacedBlocks() {
    return widget.placedBlocks.map((block) {
      final x = (block['x'] as double? ?? 0.0) * 60.0 + 200.0;
      final y = (block['y'] as double? ?? 0.0) * 60.0 + 200.0;
      final z = (block['z'] as double? ?? 0.0) * 10.0;

      return Positioned(
        left: x,
        top: y - z,
        child: GestureDetector(
          onTap: () => widget.onBlockSelected(block),
          child: _buildBlock(
            color: block['color'] as Color,
            texture: block['texture'] as String,
            isGhost: false,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildGhostBlock() {
    if (_ghostBlockPosition == null) return const SizedBox.shrink();

    return Positioned(
      left: _ghostBlockPosition!.dx,
      top: _ghostBlockPosition!.dy,
      child: _buildBlock(
        color: widget.selectedBlock['color'] as Color,
        texture: widget.selectedBlock['texture'] as String,
        isGhost: true,
      ),
    );
  }

  Widget _buildBlock({
    required Color color,
    required String texture,
    required bool isGhost,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: isGhost ? 100 : 200),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isGhost ? 0.5 : 1.0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGhost
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8)
              : Colors.black.withValues(alpha: 0.2),
          width: isGhost ? 2 : 1,
        ),
        boxShadow: isGhost
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          children: [
            CustomImageWidget(
              imageUrl: texture,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            if (isGhost)
              Container(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'view_in_ar',
              color: AppTheme.lightTheme.primaryColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Start Building!',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a block from the palette below and tap to place it in the 3D scene.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInstructionItem(
                  icon: 'touch_app',
                  text: 'Tap to place',
                ),
                const SizedBox(width: 16),
                _buildInstructionItem(
                  icon: 'pinch',
                  text: 'Pinch to zoom',
                ),
                const SizedBox(width: 16),
                _buildInstructionItem(
                  icon: 'rotate_right',
                  text: 'Drag to rotate',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required String icon,
    required String text,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: icon,
          color: AppTheme.getNeutralColor(true),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: AppTheme.lightTheme.textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _onTap() {
    if (!widget.isBuildMode) return;

    if (widget.isPlacementMode && _ghostBlockPosition != null) {
      // Calculate grid position from screen position
      final gridX =
          ((_ghostBlockPosition!.dx - 200.0) / 60.0).round().toDouble();
      final gridY =
          ((_ghostBlockPosition!.dy - 200.0) / 60.0).round().toDouble();

      widget.onBlockPlaced({
        'x': gridX,
        'y': gridY,
        'z': 0.0,
      });

      setState(() {
        _ghostBlockPosition = null;
      });
    }
  }

  void _onLongPress() {
    widget.onModeChanged(!widget.isBuildMode);
    HapticFeedback.mediumImpact();
  }

  void _onScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
    _previousOffset = _offset;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!widget.isBuildMode) {
      setState(() {
        _scale = (_previousScale * details.scale).clamp(0.5, 3.0);
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // Scale gesture ended
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isBuildMode && widget.isPlacementMode) {
      // Update ghost block position
      setState(() {
        _ghostBlockPosition = details.localPosition;
      });
    } else if (!widget.isBuildMode) {
      // Pan the view
      setState(() {
        _offset += details.delta;
      });
    }
  }

  void _toggleMode() {
    widget.onModeChanged(!widget.isBuildMode);
  }

  void _resetView() {
    setState(() {
      _scale = 1.0;
      _offset = Offset.zero;
      _rotationX = 0.0;
      _rotationY = 0.0;
    });
    HapticFeedback.lightImpact();
  }
}

class GridPainter extends CustomPainter {
  final Color gridColor;
  final double gridSize;

  GridPainter({
    required this.gridColor,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
