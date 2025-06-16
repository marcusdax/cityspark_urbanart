import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/particle_animation_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  bool _isInitializing = true;
  String _loadingText = 'Initializing AR Services...';
  double _progress = 0.0;

  // Mock user data for navigation logic
  final Map<String, dynamic> _mockUserData = {
    "isAuthenticated": false,
    "isFirstTime": true,
    "hasCompletedOnboarding": false,
    "arCapabilitySupported": true,
    "locationPermissionGranted": true,
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _logoController.forward();
    _particleController.repeat();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate AR services initialization
      await _simulateInitialization();

      // Navigate based on user state
      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        _handleInitializationError();
      }
    }
  }

  Future<void> _simulateInitialization() async {
    final List<Map<String, String>> initSteps = [
      {"text": "Initializing AR Services...", "duration": "800"},
      {"text": "Checking AR Compatibility...", "duration": "600"},
      {"text": "Loading User Preferences...", "duration": "500"},
      {"text": "Preparing Map Data...", "duration": "700"},
      {"text": "Setting up Location Services...", "duration": "400"},
    ];

    for (int i = 0; i < initSteps.length; i++) {
      if (mounted) {
        setState(() {
          _loadingText = initSteps[i]["text"]!;
          _progress = (i + 1) / initSteps.length;
        });

        await Future.delayed(
            Duration(milliseconds: int.parse(initSteps[i]["duration"]!)));
      }
    }

    // Final delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToNextScreen() {
    final bool isAuthenticated = _mockUserData["isAuthenticated"] as bool;
    final bool isFirstTime = _mockUserData["isFirstTime"] as bool;
    final bool arSupported = _mockUserData["arCapabilitySupported"] as bool;
    final bool locationGranted =
        _mockUserData["locationPermissionGranted"] as bool;

    String nextRoute;

    if (!arSupported) {
      _showARCompatibilityWarning();
      return;
    }

    if (!locationGranted) {
      _showLocationPermissionPrompt();
      return;
    }

    if (isFirstTime || !(_mockUserData["hasCompletedOnboarding"] as bool)) {
      nextRoute = '/ar-onboarding-tutorial';
    } else if (isAuthenticated) {
      nextRoute = '/interactive-city-map';
    } else {
      nextRoute = '/interactive-city-map'; // For demo purposes
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  void _handleInitializationError() {
    setState(() {
      _loadingText = 'Initialization failed. Retrying...';
      _isInitializing = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _initializeApp();
      }
    });
  }

  void _showARCompatibilityWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'AR Not Supported',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Your device does not support AR functionality. Some features may be limited.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(
                    context, '/interactive-city-map');
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Location Permission Required',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'CitySpark needs location access to show nearby cleanup opportunities.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(
                    context, '/interactive-city-map');
              },
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // In real app, would open settings
                Navigator.pushReplacementNamed(
                    context, '/interactive-city-map');
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide status bar on Android, match brand color on iOS
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.secondary,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Particle animation background
              ParticleAnimationWidget(
                controller: _particleController,
              ),

              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated logo section
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Opacity(
                          opacity: _logoFadeAnimation.value,
                          child: AnimatedLogoWidget(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // App title
                  AnimatedBuilder(
                    animation: _logoFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'CitySpark',
                              style: AppTheme.lightTheme.textTheme.headlineLarge
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'UrbanArt',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // Loading section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        LoadingIndicatorWidget(
                          progress: _progress,
                          isLoading: _isInitializing,
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _loadingText,
                            key: ValueKey(_loadingText),
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
