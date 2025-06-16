import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticleAnimationWidget extends StatelessWidget {
  final AnimationController controller;

  const ParticleAnimationWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            animationValue: controller.value,
            screenSize: MediaQuery.of(context).size,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  final Size screenSize;
  final List<Particle> particles = [];

  ParticlePainter({
    required this.animationValue,
    required this.screenSize,
  }) {
    _generateParticles();
  }

  void _generateParticles() {
    final random = math.Random(42); // Fixed seed for consistent animation

    for (int i = 0; i < 20; i++) {
      particles.add(Particle(
        x: random.nextDouble() * screenSize.width,
        y: random.nextDouble() * screenSize.height,
        size: random.nextDouble() * 4 + 2,
        speed: random.nextDouble() * 2 + 1,
        opacity: random.nextDouble() * 0.3 + 0.1,
        phase: random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final currentY = particle.y +
          (animationValue * particle.speed * 100) % screenSize.height;

      final currentOpacity = particle.opacity *
          (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi + particle.phase));

      paint.color = Colors.white.withValues(alpha: currentOpacity);

      canvas.drawCircle(
        Offset(particle.x, currentY),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double phase;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}
