import 'package:flutter/material.dart';

class OutlinedCard extends StatelessWidget {
  final Color? color;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final double radius;
  final Color? shadowColor;
  const OutlinedCard({
    super.key,
    this.color,
    required this.child,
    this.margin,
    this.elevation = 1.0,
    this.radius = 25,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      shadowColor: shadowColor,
      elevation: elevation,
      margin: margin,
      child: child,
    );
  }
}
