import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ArPaintingWidget extends StatefulWidget {
  final VoidCallback onClose;

  const ArPaintingWidget({
    super.key,
    required this.onClose,
  });

  @override
  State<ArPaintingWidget> createState() => _ArPaintingWidgetState();
}

class _ArPaintingWidgetState extends State<ArPaintingWidget> {
  Color selectedColor = Colors.red;
  double brushSize = 10.0;
  List<Offset?> paintPoints = [];

  final List<Color> paintColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Stack(
        children: [
          // Painting canvas
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  paintPoints.add(details.localPosition);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  paintPoints.add(null);
                });
              },
              child: CustomPaint(
                painter: PaintingCanvasPainter(
                  points: paintPoints,
                  color: selectedColor,
                  brushSize: brushSize,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          // Color palette
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: paintColors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Brush size slider
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Brush Size',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'brush',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 16,
                      ),
                      Expanded(
                        child: Slider(
                          value: brushSize,
                          min: 5.0,
                          max: 30.0,
                          divisions: 5,
                          onChanged: (value) {
                            setState(() {
                              brushSize = value;
                            });
                          },
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'brush',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),

          // Clear canvas button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  paintPoints.clear();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaintingCanvasPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double brushSize;

  PaintingCanvasPainter({
    required this.points,
    required this.color,
    required this.brushSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = brushSize;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
