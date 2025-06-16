import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class GestureHintWidget extends StatefulWidget {
  final String gestureType;

  const GestureHintWidget({
    super.key,
    required this.gestureType,
  });

  @override
  State<GestureHintWidget> createState() => _GestureHintWidgetState();
}

class _GestureHintWidgetState extends State<GestureHintWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: Center(
              child: _buildGestureIcon(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGestureIcon() {
    switch (widget.gestureType) {
      case 'move_camera':
        return CustomIconWidget(
          iconName: 'camera_alt',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        );
      case 'tap':
        return CustomIconWidget(
          iconName: 'touch_app',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        );
      case 'camera_tap':
        return CustomIconWidget(
          iconName: 'photo_camera',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        );
      case 'paint_swipe':
        return CustomIconWidget(
          iconName: 'brush',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        );
      default:
        return CustomIconWidget(
          iconName: 'help',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        );
    }
  }
}
