// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/gradient_widgets.dart';

import 'theming.dart';

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
  final List<Widget> children;
  final ExFabController? controller;
  const ExpandableFab({super.key, required this.children, this.controller});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            ..._buildExpandingActionButtons(),
            buildButton(),
          ],
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
    _expandAnimation = CurvedAnimation(
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

  Widget buildButton() {
    return GestureDetector(
      onTap: toggle,
      child: AnimatedContainer(
        duration: Durations.short1,
        decoration: _open ? Theming.gradientDeco : Theming.innerDeco,
        width: 56,
        height: 56,
        child: AnimatedContainer(
          width: _open ? 50 : 56,
          height: _open ? 50 : 56,
          margin: _open ? EdgeInsets.all(Theming.padding) : null,
          duration: Durations.short3,
          decoration: _open ? Theming.innerDeco : Theming.innerDeco.copyWith(gradient: Theming.coloredGradient),
          child: Center(child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _controller)),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, offset = 0.0; i < count; i++, offset += step) {
      children.add(
        ExpandingActionButton(
          index: i.toDouble(),
          progress: _expandAnimation,
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
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed!(),
      child: Align(
        alignment: Alignment.center,
        child: GradientOutline(
          innerPadding: 10,
          outerPadding: 5,
          gradient: Theming.grayGradient,
          child: icon,
        ),
      ),
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
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset(0, ((index + 1) * 60) * progress.value);

        return Positioned(
          bottom: 10 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * 3.141592653 / 2,
            child: child!,
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
