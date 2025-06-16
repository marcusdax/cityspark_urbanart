import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class PhotoCaptureWidget extends StatefulWidget {
  final bool isCapturing;
  final VoidCallback onCapture;

  const PhotoCaptureWidget({
    super.key,
    required this.isCapturing,
    required this.onCapture,
  });

  @override
  State<PhotoCaptureWidget> createState() => _PhotoCaptureWidgetState();
}

class _PhotoCaptureWidgetState extends State<PhotoCaptureWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
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

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
      widget.onCapture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isCapturing ? null : _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isCapturing
                    ? Colors.grey.withValues(alpha: 0.5)
                    : Colors.white,
                border: Border.all(
                  color: AppTheme.lightTheme.primaryColor,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.isCapturing
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppTheme.lightTheme.primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                        child: CustomIconWidget(
                          iconName: 'camera_alt',
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
