import 'package:flutter/material.dart';

class EdgeSwipeBack extends StatefulWidget {
  const EdgeSwipeBack({
    super.key,
    required this.child,
    this.onSwipeBack,
    this.edgeWidth = 36,
    this.triggerDistance = 72,
  });

  final Widget child;
  final Future<void> Function()? onSwipeBack;
  final double edgeWidth;
  final double triggerDistance;

  @override
  State<EdgeSwipeBack> createState() => _EdgeSwipeBackState();
}

class _EdgeSwipeBackState extends State<EdgeSwipeBack> {
  _SwipeEdge _activeEdge = _SwipeEdge.none;
  double _dragDelta = 0;
  bool _isHandling = false;

  void _onDragStart(DragStartDetails details) {
    if (_isHandling) {
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    if (dx <= widget.edgeWidth) {
      _activeEdge = _SwipeEdge.left;
      _dragDelta = 0;
      return;
    }

    if (dx >= screenWidth - widget.edgeWidth) {
      _activeEdge = _SwipeEdge.right;
      _dragDelta = 0;
      return;
    }

    _activeEdge = _SwipeEdge.none;
    _dragDelta = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_activeEdge == _SwipeEdge.none || _isHandling) {
      return;
    }

    _dragDelta += details.delta.dx;
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (_activeEdge == _SwipeEdge.none || _isHandling) {
      _activeEdge = _SwipeEdge.none;
      _dragDelta = 0;
      return;
    }

    final passedThreshold =
        _activeEdge == _SwipeEdge.left
            ? _dragDelta >= widget.triggerDistance
            : _dragDelta <= -widget.triggerDistance;

    _activeEdge = _SwipeEdge.none;
    _dragDelta = 0;

    if (!passedThreshold) {
      return;
    }

    _isHandling = true;
    try {
      final action = widget.onSwipeBack;
      if (action != null) {
        await action();
      } else {
        if (!mounted) {
          return;
        }
        await Navigator.of(context).maybePop();
      }
    } finally {
      _isHandling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: widget.child,
    );
  }
}

enum _SwipeEdge { left, right, none }
