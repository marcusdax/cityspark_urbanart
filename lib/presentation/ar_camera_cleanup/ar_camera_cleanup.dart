import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/ar_overlay_widget.dart';
import './widgets/ar_painting_widget.dart';
import './widgets/photo_capture_widget.dart';
import './widgets/session_stats_widget.dart';
import './widgets/trash_detection_widget.dart';

class ArCameraCleanup extends StatefulWidget {
  const ArCameraCleanup({super.key});

  @override
  State<ArCameraCleanup> createState() => _ArCameraCleanupState();
}

class _ArCameraCleanupState extends State<ArCameraCleanup>
    with TickerProviderStateMixin {
  // Mock data for detected trash items
  final List<Map<String, dynamic>> detectedTrash = [
    {
      "id": 1,
      "type": "can",
      "position": {"x": 0.3, "y": 0.4},
      "points": 5,
      "collected": false,
      "color": Colors.red,
    },
    {
      "id": 2,
      "type": "bottle",
      "position": {"x": 0.7, "y": 0.6},
      "points": 10,
      "collected": false,
      "color": Colors.orange,
    },
    {
      "id": 3,
      "type": "barrel",
      "position": {"x": 0.5, "y": 0.3},
      "points": 15,
      "collected": false,
      "color": Colors.yellow,
    },
  ];

  // Session state
  int totalScore = 0;
  int collectedItems = 0;
  bool isPaintingMode = false;
  bool isCapturingPhoto = false;
  String? capturedPhotoPath;
  Timer? sessionTimer;
  int sessionDuration = 0;
  double pointMultiplier = 1.0;

  // Animation controllers
  late AnimationController _scoreAnimationController;
  late AnimationController _collectAnimationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _collectAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSessionTimer();
    _updatePointMultiplier();
  }

  void _initializeAnimations() {
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _collectAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.elasticOut,
    ));

    _collectAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _collectAnimationController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startSessionTimer() {
    sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        sessionDuration++;
      });
    });
  }

  void _updatePointMultiplier() {
    // Increase multiplier based on session duration
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          pointMultiplier = min(3.0, 1.0 + (sessionDuration / 300));
        });
      }
    });
  }

  void _collectTrashItem(int itemId) {
    final itemIndex = detectedTrash.indexWhere((item) => item["id"] == itemId);
    if (itemIndex != -1 && !detectedTrash[itemIndex]["collected"]) {
      setState(() {
        detectedTrash[itemIndex]["collected"] = true;
        final points =
            (detectedTrash[itemIndex]["points"] * pointMultiplier).round();
        totalScore += points as int;
        collectedItems++;
      });

      // Trigger haptic feedback
      HapticFeedback.mediumImpact();

      // Animate score update
      _scoreAnimationController.forward().then((_) {
        _scoreAnimationController.reverse();
      });

      // Animate collection
      _collectAnimationController.forward().then((_) {
        _collectAnimationController.reverse();
      });
    }
  }

  void _togglePaintingMode() {
    setState(() {
      isPaintingMode = !isPaintingMode;
    });
    HapticFeedback.selectionClick();
  }

  void _capturePhoto() {
    setState(() {
      isCapturingPhoto = true;
    });

    // Simulate photo capture
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isCapturingPhoto = false;
        capturedPhotoPath =
            "captured_photo_${DateTime.now().millisecondsSinceEpoch}.jpg";
      });
      HapticFeedback.heavyImpact();
    });
  }

  String _formatSessionTime() {
    final minutes = sessionDuration ~/ 60;
    final seconds = sessionDuration % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    sessionTimer?.cancel();
    _scoreAnimationController.dispose();
    _collectAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withValues(alpha: 0.3),
                  Colors.green.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: CustomImageWidget(
              imageUrl:
                  "https://images.pexels.com/photos/2382894/pexels-photo-2382894.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // AR Overlay with detected trash
          ArOverlayWidget(
            detectedTrash: detectedTrash,
            onTrashTap: _collectTrashItem,
            collectAnimation: _collectAnimation,
          ),

          // Trash detection highlights
          ...detectedTrash.map((item) => TrashDetectionWidget(
                item: item,
                onTap: () => _collectTrashItem(item["id"]),
                animation: _collectAnimation,
              )),

          // Top UI overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score display
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scoreAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface
                              .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.lightTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'stars',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              totalScore.toString(),
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Session stats
                SessionStatsWidget(
                  sessionTime: _formatSessionTime(),
                  pointMultiplier: pointMultiplier,
                ),

                // Painting mode toggle
                GestureDetector(
                  onTap: _togglePaintingMode,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPaintingMode
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.surface
                              .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.lightTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'brush',
                      color: isPaintingMode
                          ? Colors.white
                          : AppTheme.lightTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // AR Painting overlay
          if (isPaintingMode)
            ArPaintingWidget(
              onClose: () => setState(() => isPaintingMode = false),
            ),

          // Bottom UI overlay
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Photo preview thumbnail
                if (capturedPhotoPath != null)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CustomImageWidget(
                        imageUrl:
                            "https://images.pexels.com/photos/3735747/pexels-photo-3735747.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 60),

                // Photo capture button
                PhotoCaptureWidget(
                  isCapturing: isCapturingPhoto,
                  onCapture: _capturePhoto,
                ),

                // Collected items counter
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'delete',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        collectedItems.toString(),
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),

          // Loading overlay during photo capture
          if (isCapturingPhoto)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Capturing Photo...',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}