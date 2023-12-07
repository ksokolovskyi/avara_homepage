import 'package:flutter/material.dart';

class FocusShadow extends StatefulWidget {
  const FocusShadow({
    required this.color,
    required this.focusNode,
    required this.child,
    super.key,
  });

  final Color color;

  final FocusNode focusNode;

  final Widget child;

  @override
  State<FocusShadow> createState() => _FocusShadowState();
}

class _FocusShadowState extends State<FocusShadow>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final _opacity =
      CurveTween(curve: Curves.easeInOut).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: _controller.value == 0
                  ? null
                  : [
                      BoxShadow(
                        blurRadius: 15 * 5,
                        spreadRadius: 7 * 5,
                        color: widget.color.withOpacity(0.4 * _opacity.value),
                      ),
                    ],
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}
