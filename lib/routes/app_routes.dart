import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/3d_design_builder/3d_design_builder.dart';
import '../presentation/ar_camera_cleanup/ar_camera_cleanup.dart';
import '../presentation/interactive_city_map/interactive_city_map.dart';
import '../presentation/ar_onboarding_tutorial/ar_onboarding_tutorial.dart';
import '../presentation/community_voting_gallery/community_voting_gallery.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String arOnboardingTutorial = '/ar-onboarding-tutorial';
  static const String interactiveCityMap = '/interactive-city-map';
  static const String arCameraCleanup = '/ar-camera-cleanup';
  static const String threeDDesignBuilder = '/3d-design-builder';
  static const String communityVotingGallery = '/community-voting-gallery';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    arOnboardingTutorial: (context) => const ArOnboardingTutorial(),
    interactiveCityMap: (context) => const InteractiveCityMap(),
    arCameraCleanup: (context) => const ArCameraCleanup(),
    threeDDesignBuilder: (context) => const ThreeDDesignBuilder(),
    communityVotingGallery: (context) => const CommunityVotingGallery(),
  };
}
