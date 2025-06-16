import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ArOverlayWidget extends StatelessWidget {
  final List<Map<String, dynamic>> detectedTrash;
  final Function(int) onTrashTap;
  final Animation<double> collectAnimation;

  const ArOverlayWidget({
    super.key,
    required this.detectedTrash,
    required this.onTrashTap,
    required this.collectAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: detectedTrash.map((item) {
        final position = item["position"] as Map<String, dynamic>;
        final isCollected = item["collected"] as bool;

        if (isCollected) return const SizedBox.shrink();

        return Positioned(
          left: (position["x"] as double) * screenSize.width - 30,
          top: (position["y"] as double) * screenSize.height - 30,
          child: AnimatedBuilder(
            animation: collectAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (collectAnimation.value * 0.3),
                child: GestureDetector(
                  onTap: () => onTrashTap(item["id"]),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item["color"] as Color,
                        width: 3,
                      ),
                      color: (item["color"] as Color).withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: _getIconForTrashType(item["type"]),
                            color: item["color"] as Color,
                            size: 20,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+${item["points"]}',
                            style: TextStyle(
                              color: item["color"] as Color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
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
