import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

import '../utils/theming.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 2),
      () => Navigator.push(
        context,
        PageRouteBuilder(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          pageBuilder: (_, __, ___) => const MyApp(),
        ),
      ),
    );

    const double size = 250;

    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Color.fromARGB(255, 14, 14, 14)],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Study App', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: size + 50),
                ],
              ),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) => const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  tileMode: TileMode.repeated,
                  colors: Theming.gradientColors,
                ).createShader(Rect.fromCenter(center: bounds.center, width: size, height: size)),
                child: const Icon(
                  Icons.school_rounded,
                  size: size,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
