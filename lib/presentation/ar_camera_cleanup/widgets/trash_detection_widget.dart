import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TrashDetectionWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final Animation<double> animation;

  const TrashDetectionWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.animation,
  });

  @override
  State<TrashDetectionWidget> createState() => _TrashDetectionWidgetState();
}

class _TrashDetectionWidgetState extends State<TrashDetectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (!widget.item["collected"]) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item["collected"]) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final position = widget.item["position"] as Map<String, dynamic>;

    return Positioned(
      left: (position["x"] as double) * screenSize.width - 40,
      top: (position["y"] as double) * screenSize.height - 40,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.item["color"] as Color,
                    width: 2,
                  ),
                  color: (widget.item["color"] as Color).withValues(alpha: 0.1),
                ),
                child: Stack(
                  children: [
                    // Outer glow effect
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.item["color"] as Color)
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Inner content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: _getIconForTrashType(widget.item["type"]),
                            color: widget.item["color"] as Color,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.item["color"] as Color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+${widget.item["points"]}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getIconForTrashType(String type) {
    switch (type) {
      case 'can':
        return 'local_drink';
      case 'bottle':
        return 'local_bar';
      case 'barrel':
        return 'delete_outline';
      default:
        return 'delete';
    }
  }
}
