import 'package:flutter/material.dart';
import 'theming.dart';

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
