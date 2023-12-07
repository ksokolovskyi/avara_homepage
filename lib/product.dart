import 'package:audioplayers/audioplayers.dart';
import 'package:avara_homepage/assets/assets.dart';
import 'package:avara_homepage/focus_shadow.dart';
import 'package:avara_homepage/spring_simulation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Product extends StatefulWidget {
  const Product({
    required this.player,
    required this.asset,
    required this.aspectRatio,
    required this.focusColor,
    required this.opacity,
    super.key,
  });

  final AudioPlayer player;

  final String asset;

  final double aspectRatio;

  final Color focusColor;

  final Animation<double> opacity;

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> with TickerProviderStateMixin {
  late final _simulation = AvaraSpringSimulation(
    tickerProvider: this,
    spring: const SpringDescription(
      mass: 1,
      stiffness: 500,
      damping: 15,
    ),
  );

  late final _scaleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final _scaleAnimation = Tween<double>(begin: 1, end: 1.1)
      .chain(CurveTween(curve: Curves.easeOut))
      .animate(_scaleController);

  late final _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final _rotationAnimation = CurveTween(
    curve: Curves.easeOut,
  ).animate(_rotationController);

  final _focusNode = FocusNode();

  final ValueNotifier<SystemMouseCursor> _cursor = ValueNotifier(_grabCursor);

  static const _grabCursor = SystemMouseCursors.grab;
  static const _grabbingCursor = SystemMouseCursors.grabbing;

  bool _isDragging = false;

  late final _listenable = Listenable.merge([
    _simulation,
    _scaleAnimation,
    _rotationAnimation,
  ]);

  @override
  void initState() {
    super.initState();
    _simulation
      ..anchorPosition = Offset.zero
      ..springPosition = Offset.zero;
  }

  @override
  void dispose() {
    _simulation.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _play(String asset) {
    return widget.player.play(AssetSource(asset));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _listenable,
      builder: (context, child) {
        final offset = _simulation.springPosition;
        final scale = _scaleAnimation.value;
        final angle = _rotationAnimation.value * 0.17;

        final transform = Matrix4.identity()
          ..translate(offset.dx, offset.dy)
          ..scale(scale, scale, 1)
          ..rotateZ(angle);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: child,
        );
      },
      child: ValueListenableBuilder(
        valueListenable: _cursor,
        builder: (context, cursor, child) {
          return MouseRegion(
            cursor: cursor,
            onEnter: (event) {
              if (event.buttons != 0) {
                return;
              }

              _scaleController.forward();
            },
            onHover: (event) {
              if (event.buttons != 0 ||
                  _scaleController.status == AnimationStatus.forward ||
                  _scaleController.isCompleted) {
                return;
              }

              _scaleController.forward();
            },
            onExit: (_) {
              if (_isDragging) {
                return;
              }

              _scaleController.reverse();
            },
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: (details) {
            _play(AudioAssets.click);
            _cursor.value = _grabbingCursor;
            _scaleController.animateTo(0.5);

            if (!_focusNode.hasFocus) {
              FocusScope.of(context).unfocus();
            }
          },
          onTapUp: (details) {
            _play(AudioAssets.click);
            _cursor.value = _grabCursor;
            _scaleController.animateTo(1);
          },
          onPanStart: (details) {
            _cursor.value = _grabbingCursor;
            _simulation.end();
            _rotationController.forward();
          },
          onPanUpdate: (details) {
            if (!_isDragging) {
              _play(AudioAssets.tap);
              _isDragging = true;
            }

            _simulation.springPosition += details.delta;
          },
          onPanEnd: (details) {
            _play(_isDragging ? AudioAssets.release : AudioAssets.click);

            _isDragging = false;

            _cursor.value = _grabCursor;

            _simulation.start();

            _rotationController.reverse();
          },
          child: FocusShadow(
            color: widget.focusColor,
            focusNode: _focusNode,
            child: AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: Image.asset(
                widget.asset,
                fit: BoxFit.contain,
                opacity: widget.opacity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
