import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class ArPaintingOverlayWidget extends StatefulWidget {
  final Function(Color) onColorSelected;
  final Function(double) onBrushSizeChanged;

  const ArPaintingOverlayWidget({
    super.key,
    required this.onColorSelected,
    required this.onBrushSizeChanged,
  });

  @override
  State<ArPaintingOverlayWidget> createState() =>
      _ArPaintingOverlayWidgetState();
}

class _ArPaintingOverlayWidgetState extends State<ArPaintingOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Color selectedColor = const Color(0xFF4CAF50);
  double brushSize = 5.0;

  final List<Color> paintColors = [
    const Color(0xFF4CAF50), // Green
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFF9800), // Orange
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFFFF5722), // Red
    const Color(0xFF795548), // Brown
  ];

  final List<Offset> paintStrokes = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Paint Canvas Area
        Positioned.fill(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                paintStrokes.add(details.localPosition);
              });
            },
            child: CustomPaint(
              painter: ARPaintPainter(
                strokes: paintStrokes,
                color: selectedColor,
                brushSize: brushSize,
              ),
            ),
          ),
        ),

        // Color Palette
        Positioned(
          left: 16,
          top: MediaQuery.of(context).size.height * 0.3,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: paintColors.map((color) {
                      final bool isSelected = color == selectedColor;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                          widget.onColorSelected(color);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),

        // Brush Size Slider
        Positioned(
          right: 16,
          top: MediaQuery.of(context).size.height * 0.3,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  height: 200,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'brush',
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Slider(
                            value: brushSize,
                            min: 2.0,
                            max: 20.0,
                            divisions: 18,
                            activeColor:
                                AppTheme.lightTheme.colorScheme.primary,
                            inactiveColor: Colors.white.withValues(alpha: 0.3),
                            onChanged: (value) {
                              setState(() {
                                brushSize = value;
                              });
                              widget.onBrushSizeChanged(value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: brushSize,
                        height: brushSize,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Painting Instructions
        Positioned(
          bottom: 200,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'palette',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AR Painting Mode',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Swipe on screen to paint • Tap colors to change • Adjust brush size',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Clear Button
        Positioned(
          bottom: 120,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            onPressed: () {
              setState(() {
                paintStrokes.clear();
              });
            },
            child: CustomIconWidget(
              iconName: 'clear',
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class ARPaintPainter extends CustomPainter {
  final List<Offset> strokes;
  final Color color;
  final double brushSize;

  ARPaintPainter({
    required this.strokes,
    required this.color,
    required this.brushSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = brushSize;

    for (int i = 0; i < strokes.length - 1; i++) {
      if (strokes[i] != Offset.zero && strokes[i + 1] != Offset.zero) {
        canvas.drawLine(strokes[i], strokes[i + 1], paint);
      }
    }

    // Draw individual points for single taps
    for (final stroke in strokes) {
      if (stroke != Offset.zero) {
        canvas.drawCircle(stroke, brushSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
