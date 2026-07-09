import 'package:flutter/material.dart';

class SwipeableButtonWidget extends StatefulWidget {
  final VoidCallback action;
  final Widget label;
  final Widget icon;
  final Color backgroundColor;
  final Color buttonColor;
  final Color baseColor;
  final Color highlightedColor;

  const SwipeableButtonWidget({
    super.key,
    required this.action,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.buttonColor,
    required this.baseColor,
    required this.highlightedColor,
  });

  @override
  State<SwipeableButtonWidget> createState() => _SwipeableButtonWidgetState();
}

class _SwipeableButtonWidgetState extends State<SwipeableButtonWidget> with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isCompleted = false;
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;
  double _trackWidth = 0.0;

  static const double _thumbSize = 52.0;
  static const double _padding = 6.0;
  static const double _height = 64.0;

  double get _maxDrag => _trackWidth - _thumbSize - _padding * 2;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isCompleted) return;
    setState(() {
      _dragPosition =
          (_dragPosition + details.delta.dx).clamp(0.0, _maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isCompleted) return;
    final threshold = _maxDrag * 0.75;

    if (_dragPosition >= threshold) {
      _snapAnimation = Tween<double>(begin: _dragPosition, end: _maxDrag).animate(CurvedAnimation(parent: _snapController, curve: Curves.easeOut));
      _snapAnimation.addListener(() => setState(() => _dragPosition = _snapAnimation.value));
      _snapController.forward(from: 0).then((_) {
        setState(() => _isCompleted = true);
        widget.action();

        _snapController.forward(from: 0).then((_) {
          widget.action();
          _reset();
        });
      });
    } else {
      _snapAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(CurvedAnimation(parent: _snapController, curve: Curves.elasticOut));
      _snapAnimation.addListener(() => setState(() => _dragPosition = _snapAnimation.value));
      _snapController.forward(from: 0);
    }
  }

  void _reset() {
    _snapController.reset();
    setState(() {
      _dragPosition = 0.0;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _trackWidth = constraints.maxWidth;
      final progress = _maxDrag > 0 ? (_dragPosition / _maxDrag).clamp(0.0, 1.0) : 0.0;

      return GestureDetector(
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Container(
          height: _height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(_height / 2),
          ),
          child: Stack(
            children: [
              // Highlight fill that grows behind the thumb
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: _padding + _dragPosition + _thumbSize,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.highlightedColor.withValues(alpha: 0.15 * progress),
                    borderRadius: BorderRadius.circular(_height / 2),
                  ),
                ),
              ),

              // Label fades out as thumb moves right
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: _thumbSize + _padding * 2),
                    child: Opacity(
                      opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
                      child: widget.label,
                    ),
                  ),
                ),
              ),

              // Draggable thumb
              Positioned(
                left: _padding + _dragPosition,
                top: _padding,
                child: Container(
                  width: _thumbSize,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    color: widget.buttonColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.buttonColor.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child:  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 22)
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}