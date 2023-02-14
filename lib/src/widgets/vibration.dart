import 'dart:async';
import 'package:flutter/material.dart';

// TODO: Code review, improve, refactor, etc.

class VibrationController {
  final StreamController<bool> _events = StreamController<bool>.broadcast();
  Stream<bool> get stream => _events.stream;

  /// Events are not buffered, so the widget must be rendered and initialized so it subscribes
  /// (throws an error if there are no listeners.)
  void vibrate() {
    if (!_events.hasListener) {
      throw Exception('Not being listened to');
    }
    _events.add(true);
  }

  void dispose() {
    // ignore: discarded_futures
    _events.close();
  }
}

class Vibration extends StatefulWidget {
  const Vibration({super.key, required this.child, required this.controller});

  final Widget child;
  final VibrationController controller;

  @override
  State<StatefulWidget> createState() => _VibrationState();
}

class _VibrationState extends State<Vibration>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 0.5)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_animationController)
      ..addStatusListener((final AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });

    _subscription ??= widget.controller.stream.listen((final bool _) {
      _animationController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    // ignore: discarded_futures
    _subscription?.cancel();
  }

  @override
  Widget build(final BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (final BuildContext context, final Widget? _) {
        return Transform.rotate(
          angle: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
