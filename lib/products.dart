import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:avara_homepage/assets/assets.dart';
import 'package:avara_homepage/idle.dart';
import 'package:avara_homepage/product.dart';
import 'package:flutter/material.dart';

enum _Alignment {
  top,
  center,
  bottom,
}

enum _Product {
  aave,
  family,
  lens,
  sonar,
  gho,
  bean;

  String get asset {
    return switch (this) {
      aave => ImageAssets.aave,
      family => ImageAssets.family,
      lens => ImageAssets.lens,
      sonar => ImageAssets.sonar,
      gho => ImageAssets.gho,
      bean => ImageAssets.bean,
    };
  }

  double get maxWidth {
    return switch (this) {
      aave => 243,
      family => 203,
      lens => 272,
      sonar => 193,
      gho => 246,
      bean => 257,
    };
  }

  double get aspectRatio {
    return switch (this) {
      aave => 0.86,
      family => 1,
      lens => 1.39,
      sonar => 1,
      gho => 1,
      bean => 1.46,
    };
  }

  double get angle {
    return switch (this) {
      aave => -0.16,
      family => 0.05,
      lens => 0.10,
      sonar => 0,
      gho => 0.13,
      bean => 0,
    };
  }

  _Alignment get alignment {
    return switch (this) {
      aave => _Alignment.center,
      family => _Alignment.center,
      lens => _Alignment.bottom,
      sonar => _Alignment.center,
      gho => _Alignment.bottom,
      bean => _Alignment.bottom,
    };
  }

  Color get focusColor {
    return switch (this) {
      aave || gho => const Color(0xFFF0BDFA),
      family || sonar => const Color(0xFFF1A382),
      lens => const Color(0xFFB6F5C4),
      bean => const Color(0xFFFCEFAB),
    };
  }
}

class Products extends StatefulWidget {
  const Products({
    required this.player,
    super.key,
  });

  final AudioPlayer player;

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products>
    with SingleTickerProviderStateMixin {
  static const _delayDuration = Duration(milliseconds: 500);
  static const _appearanceDuration = Duration(milliseconds: 750);
  static const _staggerDuration = Duration(milliseconds: 75);
  static final _duration = _delayDuration +
      _appearanceDuration +
      _staggerDuration * (_Product.values.length - 1);

  late final _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  late final _intervals = <Interval>[];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < _Product.values.length; i++) {
      final startTime = _delayDuration + _staggerDuration * i;
      final endTime = startTime + _appearanceDuration;

      _intervals.add(
        Interval(
          startTime.inMilliseconds / _duration.inMilliseconds,
          endTime.inMilliseconds / _duration.inMilliseconds,
          curve: const Cubic(0.19, 1, 0.22, 1),
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildProduct(_Product product) {
    final interval = _intervals[product.index];

    final idleDelay =
        _delayDuration + _appearanceDuration + _staggerDuration * product.index;

    final positionAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).chain(CurveTween(curve: interval)).animate(_controller);

    final scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1,
    ).chain(CurveTween(curve: interval)).animate(_controller);

    final opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1,
        ),
        weight: 0.6,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1),
        weight: 0.2,
      ),
    ]).chain(CurveTween(curve: interval)).animate(_controller);

    final angleAnimation = Tween<double>(
      begin: 0,
      end: product.angle,
    ).chain(CurveTween(curve: interval)).animate(_controller);

    final listenable = Listenable.merge([
      positionAnimation,
      scaleAnimation,
      opacityAnimation,
      angleAnimation,
    ]);

    return LayoutId(
      id: product,
      child: ListenableBuilder(
        listenable: listenable,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..scale(
                scaleAnimation.value,
                scaleAnimation.value,
              )
              ..rotateZ(angleAnimation.value),
            alignment: Alignment.center,
            child: FractionalTranslation(
              translation: positionAnimation.value,
              child: child,
            ),
          );
        },
        child: Idle(
          delay: idleDelay,
          child: Product(
            player: widget.player,
            asset: product.asset,
            aspectRatio: product.aspectRatio,
            focusColor: product.focusColor,
            opacity: opacityAnimation,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: CustomMultiChildLayout(
        delegate: _ProductsLayoutDelegate(),
        children: [
          _buildProduct(_Product.gho),
          _buildProduct(_Product.sonar),
          _buildProduct(_Product.bean),
          _buildProduct(_Product.lens),
          _buildProduct(_Product.family),
          _buildProduct(_Product.aave),
        ],
      ),
    );
  }
}

class _ProductsLayoutDelegate extends MultiChildLayoutDelegate {
  _ProductsLayoutDelegate();

  static const _maxHeight = 280.0;

  static const _percentVisible = 0.8;

  @override
  void performLayout(Size size) {
    final height = math.min(_maxHeight, size.height);

    final center = size.center(Offset.zero);

    final sizes = <_Product, Size>{};

    for (final id in _Product.values) {
      sizes[id] = layoutChild(
        id,
        BoxConstraints(
          maxHeight: height,
          maxWidth: id.maxWidth,
        ),
      );
    }

    final width = sizes.entries.fold<double>(
      0,
      (sum, entry) {
        return entry.key == _Product.aave
            ? sum + entry.value.width
            : sum + entry.value.width * _percentVisible;
      },
    );

    var dx = (size.width - width) / 2;

    for (final id in _Product.values) {
      final productSize = sizes[id]!;

      final dy = switch (id.alignment) {
        _Alignment.top => center.dy - productSize.height / 1.5,
        _Alignment.center => center.dy - productSize.height / 2,
        _Alignment.bottom => center.dy - productSize.height / 4,
      };

      final position = Offset(dx, dy);

      positionChild(id, position);

      dx += productSize.width * _percentVisible;
    }
  }

  @override
  bool shouldRelayout(_ProductsLayoutDelegate oldDelegate) {
    return false;
  }
}
