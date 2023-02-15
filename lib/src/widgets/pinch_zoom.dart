import 'package:flutter/material.dart';

/*
 * Known issue:
 * The multi-touch may glitch a bit, triggering an "onInteractionEnd" callback, which
 * triggers an animation, which in X ms removes the overlay entry (and does other things as well).
 * The glitch mainly consists of an "interaction end", and then another "interaction start" right away,
 * which causes the original image to be zoomed, but the overlay doesn't display.
 *
 * It's important that only the overlay is displayed, because the overlay has a dark transparent background,
 * which covers the background, and also the image is rendered on top of every other widget (covers everything).
 * Simply zooming the original image is not good enough.
 *
 * This can be fixed by adding some checks, and only triggering the animation when the actual interaction finished,
 * i.e. not just because it glitched, but because the user actually stopped doing the gesture.
 *
 * As of now, it seems to be fixed. It seems that changing from a single-finger touch to a 2-finger touch triggered
 * an "onInteractionEnd" in between, so it was fixed by only triggering the animation when a 2-finger gesture finished.
 */

/*
 * How to test:
 * Test vertically and horizontally.
 * Verify it works even after rotating the phone.
 * Use child widgets that occupy the entire width, and widgets that occupy less (smaller widgets).
 * Use this widget in Row, Column, and other layouts.
 * Test on layouts with horizontal scrollbars (not tested, currently it's assumed that height is infinite/scrollable, and width is finite).
 * Temporarily use longer animation duration times to check the background opacity animation is working correctly.
 */

// TODO: Analyze this code.
class PinchZoom extends StatefulWidget {
  const PinchZoom({
    super.key,
    required this.child,
    required this.backgroundColor,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  State<StatefulWidget> createState() => _PinchZoomState();
}

class _PinchZoomState extends State<PinchZoom>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _entry;

  double _currScale = 1;
  final double _minScale = 1;
  final double _maxScale = 3;

  // TODO: This is for the reverse animation (when the user stops doing the gesture and releases the widget).
  //       I should abstract some of this logic. This widget is too bloated.
  double _lastScale = 1;
  double _lastErr = 0;

  late AnimationController _animationCtrl;
  late Animation<Matrix4>? _animation;
  late TransformationController _transformationCtrl;

  @override
  void initState() {
    super.initState();
    _transformationCtrl = TransformationController();

    _animationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )
      ..addListener(() {
        final Matrix4 currValue = _animation!.value;
        _transformationCtrl.value = currValue;

        _lastScale = _lastScale.clamp(1, _maxScale);
        final double currErr = currValue.relativeError(Matrix4.identity());
        final double p = (currErr / _lastErr).clamp(0, 1);

        _currScale = _minScale + (_lastScale - 1) * p;
        _entry!.markNeedsBuild();
      })
      ..addStatusListener((final AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _removeOverlay();
        }
      });
  }

  double _scalePercentage() {
    if (_currScale.isNaN) {
      return 0;
    }

    return (_currScale - _minScale) / (_maxScale - _minScale).clamp(0, 1);
  }

  void _buildEntry() {
    setState(() {
      _entry = OverlayEntry(
        builder: (final BuildContext _) {
          final RenderBox renderBox = context.findRenderObject()! as RenderBox;
          final Offset offset = renderBox.localToGlobal(Offset.zero);

          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: Opacity(
                  opacity: _scalePercentage() * 0.8,
                  child: Container(color: widget.backgroundColor),
                ),
              ),
              Positioned(
                // This width value must not contain padding values that were
                // added in the parent (i.e. they must be subtracted).
                // So using MediaQuery to compute the size won't work, but
                // this works correctly.
                width: renderBox.semanticBounds.width,
                left: offset.dx,
                top: offset.dy,
                child: _buildWidget(),
              )
            ],
          );
        },
      );
    });
  }

  void _removeOverlay() {
    _entry?.remove();
    setState(() {
      _entry = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _transformationCtrl.dispose();
    _animationCtrl.dispose();
    // TODO: Should overlay entry be disposed here?
  }

  bool _isZooming() {
    return _entry != null;
  }

  void _onInteractionStart(final ScaleStartDetails details) {
    if (details.pointerCount >= 2) {
      _removeOverlay();
      _buildEntry();
      Overlay.of(context).insert(_entry!);
    }
  }

  void _onInteractionUpdate(final ScaleUpdateDetails details) {
    _currScale = details.scale;
    _entry?.markNeedsBuild();
  }

  void _onInteractionEnd(final ScaleEndDetails _) {
    if (!_isZooming()) {
      return;
    }

    _animation = Matrix4Tween(
      begin: _transformationCtrl.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(
        parent: _animationCtrl,
        curve: Curves.easeOut,
      ),
    );

    _lastErr = _transformationCtrl.value.relativeError(Matrix4.identity());
    _lastScale = _currScale;
    _animationCtrl.forward(from: 0);
  }

  Widget _buildWidget() {
    return Builder(
      builder: (final BuildContext context) => InteractiveViewer(
        minScale: _minScale,
        maxScale: _maxScale,
        clipBehavior: Clip.none,
        panEnabled: false,
        onInteractionStart: _onInteractionStart,
        onInteractionUpdate: _onInteractionUpdate,
        onInteractionEnd: _onInteractionEnd,
        transformationController: _transformationCtrl,

        // This is necessary, otherwise the offset and width calculations won't work,
        // and the overlaid widget position will be wrong.
        // If this is undesired (e.g. it gets too big), arrange the layout from the parent (caller),
        // for example by wrapping the child widget in a container that makes it smaller.
        child: FittedBox(
          fit: BoxFit.fill,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => _buildWidget();
}
