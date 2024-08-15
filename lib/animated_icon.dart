import 'package:flutter/material.dart';

class IconAnimation extends StatefulWidget {
  final IconData icon;
  final double minSize;
  final double maxSize;
  final Duration duration;
  final Color? color;

  const IconAnimation({
    super.key,
    required this.icon,
    this.minSize = 25.0,
    this.maxSize = 35.0,
    this.duration = const Duration(seconds: 1),
    this.color,
  });

  @override
  IconAnimationState createState() => IconAnimationState();
}

class IconAnimationState extends State<IconAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: widget.minSize, end: widget.maxSize)
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Icon(
          widget.icon,
          size: _animation.value,
          color: widget.color,
        );
      },
    );
  }
}
