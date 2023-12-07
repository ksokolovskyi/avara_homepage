import 'dart:math' as math;

import 'package:flutter/material.dart';

class Idle extends StatefulWidget {
  const Idle({
    required this.delay,
    required this.child,
    super.key,
  });

  final Duration delay;

  final Widget child;

  @override
  State<Idle> createState() => _IdleState();
}

class _IdleState extends State<Idle> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );
  late final _animation = Tween<double>(begin: -1, end: 1)
      .chain(CurveTween(curve: Curves.easeInOut))
      .animate(_controller);

  @override
  void initState() {
    super.initState();

    _controller.value = math.Random().nextDouble();

    Future<void>.delayed(widget.delay).then((_) {
      if (!mounted) {
        return;
      }

      _controller
        ..forward()
        ..repeat(reverse: true);
    });
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
        return FractionalTranslation(
          translation: Offset(0, 0.02 * _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
