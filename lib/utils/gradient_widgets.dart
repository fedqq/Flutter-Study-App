import 'package:flutter/material.dart';
import 'theming.dart';

class GradientActionButton extends StatelessWidget {
  final Function() onPressed;
  final String tooltip;
  final Icon? icon;
  const GradientActionButton({super.key, required this.onPressed, required this.tooltip, this.icon});

  @override
  Widget build(BuildContext context) => Container(
        decoration: Theming.gradientDeco,
        child: FloatingActionButton(
          onPressed: onPressed,
          tooltip: tooltip,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          hoverElevation: 0,
          child: icon ?? const Icon(Icons.add_rounded),
        ),
      );
}

class GradientOutline extends StatelessWidget {
  final Widget? child;
  final Gradient gradient;
  final double innerPadding;
  final double outerPadding;
  const GradientOutline({
    super.key,
    required this.child,
    this.gradient = Theming.coloredGradient,
    this.innerPadding = 0,
    this.outerPadding = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Theming.transparent,
      padding: EdgeInsets.all(outerPadding),
      child: Container(
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(Theming.radius)),
        padding: EdgeInsets.all(Theming.padding),
        child: Container(decoration: Theming.innerDeco, padding: EdgeInsets.all(innerPadding), child: child),
      ),
    );
  }
}
