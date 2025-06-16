import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import './ar_painting_overlay_widget.dart';
import './virtual_trash_widget.dart';

class ArOverlayWidget extends StatefulWidget {
  final int currentStep;
  final VoidCallback onObjectTapped;
  final Map<String, dynamic> tutorialStep;

  const ArOverlayWidget({
    super.key,
    required this.currentStep,
    required this.onObjectTapped,
    required this.tutorialStep,
  });

  @override
  State<ArOverlayWidget> createState() => _ArOverlayWidgetState();
}

class _ArOverlayWidgetState extends State<ArOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;

  final List<Map<String, dynamic>> virtualTrashItems = [
    {
      "id": 1,
      "type": "bottle",
      "position": {"x": 0.3, "y": 0.6},
      "collected": false,
      "points": 5,
    },
    {
      "id": 2,
      "type": "can",
      "position": {"x": 0.7, "y": 0.4},
      "collected": false,
      "points": 5,
    },
    {
      "id": 3,
      "type": "barrel",
      "position": {"x": 0.5, "y": 0.8},
      "collected": false,
      "points": 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scanController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.linear,
    ));
  }

  void _handleTrashTap(int trashId) {
    setState(() {
      final trashIndex =
          virtualTrashItems.indexWhere((item) => item["id"] == trashId);
      if (trashIndex != -1) {
        virtualTrashItems[trashIndex]["collected"] = true;
      }
    });
    widget.onObjectTapped();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // AR Camera Simulation Background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Color(0xFF2D2D2D),
                Color(0xFF1A1A1A),
                Color(0xFF0D0D0D),
              ],
            ),
          ),
        ),

        // Surface Detection Overlay (Step 0)
        if (widget.currentStep == 0)
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: screenSize,
                painter: SurfaceScanPainter(
                  progress: _scanAnimation.value,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
            },
          ),

        // Virtual Trash Objects (Step 1)
        if (widget.currentStep == 1)
          ...virtualTrashItems.map((trash) {
            if (trash["collected"] as bool) return const SizedBox.shrink();

            return Positioned(
              left: screenSize.width * (trash["position"]["x"] as double) - 30,
              top: screenSize.height * (trash["position"]["y"] as double) - 30,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: VirtualTrashWidget(
                      trashType: trash["type"] as String,
                      points: trash["points"] as int,
                      onTap: () => _handleTrashTap(trash["id"] as int),
                    ),
                  );
                },
              ),
            );
          }),

        // Camera Capture Overlay (Step 2)
        if (widget.currentStep == 2)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          width: 4,
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'camera_alt',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // AR Painting Overlay (Step 3)
        if (widget.currentStep == 3)
          ArPaintingOverlayWidget(
            onColorSelected: (color) {},
            onBrushSizeChanged: (size) {},
          ),

        // AR Grid Lines for Reference
        if (widget.currentStep > 0)
          CustomPaint(
            size: screenSize,
            painter: ARGridPainter(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),

        // Step-specific Instructions Overlay
        Positioned(
          top: 80,
          left: 16,
          right: 16,
          child: _buildStepSpecificOverlay(),
        ),
      ],
    );
  }

  Widget _buildStepSpecificOverlay() {
    switch (widget.currentStep) {
      case 0:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'search',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Scanning for surfaces...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      case 1:
        final uncollectedCount = virtualTrashItems
            .where((item) => !(item["collected"] as bool))
            .length;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$uncollectedCount items remaining',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      case 2:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'photo_camera',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tap camera button to capture',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      case 3:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'brush',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Swipe to paint in AR space',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class SurfaceScanPainter extends CustomPainter {
  final double progress;
  final Color color;

  SurfaceScanPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;
    final currentRadius = maxRadius * progress;

    // Draw scanning circle
    canvas.drawCircle(center, currentRadius, paint);

    // Draw grid points
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        final x = (size.width / 20) * i;
        final y = (size.height / 20) * j;
        final distance =
            math.sqrt(math.pow(x - center.dx, 2) + math.pow(y - center.dy, 2));

        if (distance <= currentRadius) {
          canvas.drawCircle(Offset(x, y), 2, gridPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ARGridPainter extends CustomPainter {
  final Color color;

  ARGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (int i = 0; i <= 10; i++) {
      final x = (size.width / 10) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i <= 10; i++) {
      final y = (size.height / 10) * i;
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
