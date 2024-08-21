// ignore: unused_import
import 'dart:developer' as developer;
import 'dart:math' show pi;
import 'dart:ui';

import 'package:flutter/material.dart';

class ExFabController {
  bool open = false;
  // ignore: avoid_positional_boolean_parameters
  late void Function(bool) updateState;
  void close() {
    open = false;
    updateState(open);
  }

  void expand() {
    open = true;
    updateState(open);
  }
}

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key, required this.children, this.controller, this.onPress});
  final List<ActionButton> children;
  final ExFabController? controller;
  final VoidCallback? onPress;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> animation;
  bool _open = false;

  Widget buildWidget() => AnimatedBuilder(
        animation: animation,
        builder: (_, __) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8 * animation.value, sigmaY: 8 * animation.value),
          child: SizedBox.expand(
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

  @override
  Widget build(BuildContext context) => _open
      ? GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            toggle();
            widget.onPress?.call();
          },
          child: buildWidget(),
        )
      : buildWidget();

  // ignore: avoid_positional_boolean_parameters
  void set(bool b) {
    if (b != _open) {
      toggle();
      widget.controller?.open = b;
    }
  }

  @override
  void initState() {
    if (widget.controller != null) {
      widget.controller!.updateState = set;
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
        widget.controller?.expand();
        _controller.forward();
      } else {
        widget.controller?.close();
        _controller.reverse();
      }
    });
    widget.controller?.open = _open;
  }

  Widget buildButton() => FloatingActionButton(
        onPressed: () {
          toggle();
          widget.onPress?.call();
        },
        child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _controller),
      );

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    var step = 90.0 / (count - 1);
    if (step == double.infinity) {
      step = 1;
    }
    for (var i = 0, offset = 0; i < count; i++, offset += step.toInt()) {
      children.add(
        ExpandingActionButton(
          index: i,
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
  Widget build(BuildContext context) => IconButton(
        onPressed: onPressed,
        icon: icon,
      );
}

@immutable
class ExpandingActionButton extends StatelessWidget {
  const ExpandingActionButton({
    super.key,
    required this.index,
    required this.progress,
    required this.child,
  });

  final int index;
  final Animation<double> progress;
  final ActionButton child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final dy = (index + 1) * 60 * progress.value;

          return Positioned(
            bottom: 10 + dy,
            child: Opacity(
              opacity: progress.value,
              child: Row(
                children: [
                  Text(child.name),
                  const SizedBox(width: 10),
                  Transform.rotate(
                    angle: (1.0 - progress.value) * pi / 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
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
