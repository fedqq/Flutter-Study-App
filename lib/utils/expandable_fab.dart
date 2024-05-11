// ignore: unused_import
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'dart:math' show pi;

class ExFabController {
  bool open = false;
  late void Function(bool) updateState;
  void close() {
    open = false;
    updateState(open);
  }

  void expand() {
    open = true;
    updateState(open);
  }

  void setCallback(var func) {
    updateState = func;
  }
}

class ExpandableFab extends StatefulWidget {
  final List<ActionButton> children;
  final ExFabController? controller;
  final void Function()? onPress;
  const ExpandableFab({super.key, required this.children, this.controller, this.onPress});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> animation;
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8 * animation.value, sigmaY: 8 * animation.value),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              ..._buildExpandingActionButtons(),
              buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  void set(bool b) {
    if (b != _open) {
      toggle();
    }
  }

  @override
  void initState() {
    if (widget.controller != null) {
      widget.controller!.setCallback(set);
    }

    super.initState();
    _open = false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    animation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  void toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget buildButton() => FloatingActionButton(
        onPressed: () {
          toggle();
          if (widget.onPress != null) widget.onPress!();
        },
        child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _controller),
      );

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, offset = 0.0; i < count; i++, offset += step) {
      children.add(
        ExpandingActionButton(
          index: i.toDouble(),
          progress: animation,
          child: widget.children[i],
        ),
      );
    }

    return children;
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.name,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
    );
  }
}

@immutable
class ExpandingActionButton extends StatelessWidget {
  const ExpandingActionButton({
    super.key,
    required this.index,
    required this.progress,
    required this.child,
  });

  final double index;
  final Animation<double> progress;
  final ActionButton child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final offset = Offset(0, ((index + 1) * 60) * progress.value);

        return Positioned(
          bottom: 10 + offset.dy,
          child: Opacity(
            opacity: progress.value,
            child: Row(
              children: [
                Text(child.name),
                const SizedBox(width: 10),
                Transform.rotate(
                  angle: (1.0 - progress.value) * pi / 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}
