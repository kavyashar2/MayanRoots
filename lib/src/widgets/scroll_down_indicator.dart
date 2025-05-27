import 'package:flutter/material.dart';

class ScrollDownIndicator extends StatefulWidget {
  final ScrollController controller;
  final double bottom;
  final double right;
  final double threshold;

  const ScrollDownIndicator({
    Key? key,
    required this.controller,
    this.bottom = 18,
    this.right = 18,
    this.threshold = 10,
  }) : super(key: key);

  @override
  State<ScrollDownIndicator> createState() => _ScrollDownIndicatorState();
}

class _ScrollDownIndicatorState extends State<ScrollDownIndicator> {
  bool _showArrow = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.controller.offset > widget.threshold && _showArrow) {
      setState(() => _showArrow = false);
    } else if (widget.controller.offset <= widget.threshold && !_showArrow) {
      setState(() => _showArrow = true);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.bottom,
      right: widget.right,
      child: AnimatedOpacity(
        opacity: _showArrow ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: IgnorePointer(
          ignoring: !_showArrow,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF217055),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 38,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
} 