import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import './widgets/ar_overlay_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/tutorial_step_widget.dart';

class ArOnboardingTutorial extends StatefulWidget {
  const ArOnboardingTutorial({super.key});

  @override
  State<ArOnboardingTutorial> createState() => _ArOnboardingTutorialState();
}

class _ArOnboardingTutorialState extends State<ArOnboardingTutorial>
    with TickerProviderStateMixin {
  int currentStep = 0;
  bool isARActive = false;
  bool showCelebration = false;
  late AnimationController _animationController;
  late AnimationController _celebrationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> tutorialSteps = [
    {
      "id": 1,
      "title": "Position Your Camera",
      "description":
          "Point your camera at the ground to detect surfaces for AR objects. Move slowly for better tracking.",
      "instruction": "Hold your phone steady and scan the area",
      "gestureHint": "move_camera",
      "arAction": "surface_detection",
      "duration": 8000,
    },
    {
      "id": 2,
      "title": "Tap to Collect Trash",
      "description":
          "Green outlined objects are trash items. Tap them to collect points and clean the environment.",
      "instruction": "Tap the highlighted trash items",
      "gestureHint": "tap",
      "arAction": "trash_collection",
      "duration": 10000,
    },
    {
      "id": 3,
      "title": "Capture Before & After",
      "description":
          "Take photos to document your cleanup progress. This helps verify your environmental impact.",
      "instruction": "Tap the camera button to capture photos",
      "gestureHint": "camera_tap",
      "arAction": "photo_capture",
      "duration": 12000,
    },
    {
      "id": 4,
      "title": "AR Painting Basics",
      "description":
          "Create digital murals by painting in AR space. Use gestures to select colors and brush sizes.",
      "instruction": "Swipe to paint and tap to change colors",
      "gestureHint": "paint_swipe",
      "arAction": "ar_painting",
      "duration": 15000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startARSession();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  void _startARSession() {
    setState(() {
      isARActive = true;
    });
    // Simulate AR initialization
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        HapticFeedback.lightImpact();
      }
    });
  }

  void _nextStep() {
    if (currentStep < tutorialSteps.length - 1) {
      setState(() {
        currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
      HapticFeedback.selectionClick();
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
      HapticFeedback.selectionClick();
    }
  }

  void _skipTutorial() {
    _showSkipDialog();
  }

  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Skip Tutorial?',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to skip the AR tutorial? You can always access it later from settings.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue Tutorial',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToMap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );
  }

  void _completeTutorial() {
    setState(() {
      showCelebration = true;
    });
    _celebrationController.forward();
    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(milliseconds: 2500), () {
      _navigateToMap();
    });
  }

  void _navigateToMap() {
    Navigator.pushReplacementNamed(context, '/interactive-city-map');
  }

  void _onARObjectTapped() {
    HapticFeedback.mediumImpact();
    // Simulate successful collection
    if (currentStep == 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _nextStep();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // AR Camera View Background
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A1A),
                    Color(0xFF2D2D2D),
                    Color(0xFF1A1A1A),
                  ],
                ),
              ),
              child: isARActive
                  ? ArOverlayWidget(
                      currentStep: currentStep,
                      onObjectTapped: _onARObjectTapped,
                      tutorialStep: tutorialSteps[currentStep],
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    ),
            ),

            // Skip Button
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: _skipTutorial,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Skip',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Tutorial Step Content
            if (isARActive)
              Positioned(
                bottom: 120,
                left: 16,
                right: 16,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: TutorialStepWidget(
                          step: tutorialSteps[currentStep],
                          currentStepIndex: currentStep,
                          totalSteps: tutorialSteps.length,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Progress Indicator
            if (isARActive)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: ProgressIndicatorWidget(
                  currentStep: currentStep,
                  totalSteps: tutorialSteps.length,
                ),
              ),

            // Navigation Buttons
            if (isARActive)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Button
                    currentStep > 0
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: IconButton(
                              onPressed: _previousStep,
                              icon: CustomIconWidget(
                                iconName: 'arrow_back',
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          )
                        : const SizedBox(width: 48),

                    // Next Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: IconButton(
                        onPressed: _nextStep,
                        icon: CustomIconWidget(
                          iconName: currentStep == tutorialSteps.length - 1
                              ? 'check'
                              : 'arrow_forward',
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Celebration Overlay
            if (showCelebration)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withValues(alpha: 0.8),
                child: AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, child) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: _celebrationController.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'celebration',
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Tutorial Complete!',
                            style: AppTheme.lightTheme.textTheme.headlineSmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'re ready to start cleaning!',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
