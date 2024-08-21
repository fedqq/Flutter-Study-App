import 'package:flutter/material.dart';

Future<void> pushReplacement(BuildContext context, Widget Function() newPage) => Navigator.pushReplacement(
      context,
      PageRouteBuilder<Object?>(
        transitionDuration: Durations.extralong3,
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          const begin = Offset(0, 1);
          const end = Offset.zero;

          final tween = Tween<Offset>(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.ease,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
        pageBuilder: (_, __, ___) => newPage(),
      ),
    );
