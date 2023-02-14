import 'package:flutter/material.dart';

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
  double _scale = 1;
  final double _maxScale = 3;
  bool _zooming = false;

  late AnimationController _animationController;
  late Animation<Matrix4>? _animation;
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )
      ..addListener(() {
        _transformationController.value = _animation!.value;
      })
      ..addStatusListener((final AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _removeOverlay();
          setState(() {
            _zooming = false;
          });
        }
      });
  }

  @override
  void dispose() {
    super.dispose();
    _transformationController.dispose();
    _animationController.dispose();
  }

  ScaleStartDetails? _startDetails;

  Widget _buildWidget(
    final BuildContext context,
    final Widget child,
    final bool isOriginal,
  ) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: _maxScale,
      clipBehavior: Clip.none,
      panEnabled: false,
      onInteractionStart: (final ScaleStartDetails details) {
        setState(() {
          _startDetails = details;
        });

        debugPrint(details.toString());

        if (details.pointerCount >= 2) {
          showOverlay(context, child);
        }
      },
      onInteractionUpdate: (final ScaleUpdateDetails details) {
        _scale = details.scale;
        _entry?.markNeedsBuild();
      },
      onInteractionEnd: (final ScaleEndDetails _) {
        _animation = Matrix4Tween(
          begin: _transformationController.value,
          end: Matrix4.identity(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );

        setState(() {
          _startDetails = null;
        });

        debugPrint(_.toString());
        _animationController.forward(from: 0);
      },
      transformationController: _transformationController,
      child: Visibility(
        visible: !isOriginal || !_zooming,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: child,
      ),
    );
  }

  void showOverlay(final BuildContext context, final Widget child) {
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = MediaQuery.of(context).size;

    // TODO: Sometimes the overlay is displayed below the texts (only some videos).
    //       It should be displayed as the topmost element (i.e. covering everything else).

    print('SHowing overlay!!!!');
    setState(() {
      _zooming = true;
    });

    assert(_entry == null);
    // _removeOverlay();
    _entry = OverlayEntry(
      builder: (final BuildContext context) => Stack(
        children: <Widget>[
          Positioned.fill(
            child: Opacity(
              opacity: 0.8 * ((_scale - 1) / (_maxScale - 1)).clamp(0, 1),
              child: Container(
                color: widget.backgroundColor,
              ),
            ),
          ),
          Positioned(
            width: size.width,
            left: offset.dx,
            top: offset.dy,
            child: Opacity(
                opacity: 0.5, child: _buildWidget(context, child, false)),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_entry!);
  }

  void _removeOverlay() {
    if (_zooming) {
      return;
    }

    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: <Widget>[
        Text(_zooming ? 'Zooming' : 'Normal'),
        Text(_entry == null ? 'Entry NULL' : 'Entry PRESENT'),
        _startDetails != null
            ? Text(_startDetails!.pointerCount.toString())
            : const Text(''),
        const SizedBox(height: 40),
        _buildWidget(context, widget.child, true)
      ],
    );
  }
}
