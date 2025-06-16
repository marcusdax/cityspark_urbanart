import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class VirtualTrashWidget extends StatefulWidget {
  final String trashType;
  final int points;
  final VoidCallback onTap;

  const VirtualTrashWidget({
    super.key,
    required this.trashType,
    required this.points,
    required this.onTap,
  });

  @override
  State<VirtualTrashWidget> createState() => _VirtualTrashWidgetState();
}

class _VirtualTrashWidgetState extends State<VirtualTrashWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isCollected = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  void _handleTap() {
    if (!_isCollected) {
      setState(() {
        _isCollected = true;
      });
      widget.onTap();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCollected) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.1 + (_glowAnimation.value * 0.2),
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: _glowAnimation.value,
                ),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: _glowAnimation.value * 0.5,
                  ),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: _buildTrashIcon(),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '+${widget.points}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrashIcon() {
    switch (widget.trashType) {
      case 'bottle':
        return CustomIconWidget(
          iconName: 'local_drink',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        );
      case 'can':
        return CustomIconWidget(
          iconName: 'sports_bar',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        );
      case 'barrel':
        return CustomIconWidget(
          iconName: 'delete',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        );
      default:
        return CustomIconWidget(
          iconName: 'recycling',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        );
    }
  }
}
