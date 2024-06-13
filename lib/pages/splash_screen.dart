import 'package:flutter/material.dart';
import 'package:studyappcs/main.dart';
import 'package:studyappcs/state_managers/statistics.dart';
import 'package:studyappcs/state_managers/tests_manager.dart';

import '../utils/theming.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: Durations.extralong4);
    animation = CurvedAnimation(
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeOutQuad,
      parent: animationController,
    );
    super.initState();
  }

  void pushMain(BuildContext context) {
    Future.delayed(
      Durations.long1,
      () {
        Navigator.pop(context);

        return Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Durations.extralong3,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;

              final tween = Tween(begin: begin, end: end);
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.ease,
              );

              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            },
            pageBuilder: (_, __, ___) => const NavigationPage(title: 'Study Help App'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    StudyStatistics.load();
    TestsManager.loadData();
    animationController.forward().then((_) => pushMain(context));

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
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, __) => Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: animation.value,
                      child: Text(
                        'Study App',
                        style: TextStyle(
                          fontSize: 30 + (20 * animation.value),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: size + 50),
                  ],
                ),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) => const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    tileMode: TileMode.repeated,
                    colors: Theming.gradientColors,
                  ).createShader(
                    Rect.fromCenter(
                      center: bounds.center,
                      width: (size * animation.value),
                      height: (size * animation.value),
                    ),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: (size * animation.value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
