// ignore_for_file: always_specify_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/main.dart';
import 'package:studyappcs/pages/login_page.dart';
import 'package:studyappcs/utils/utils.dart' as theming;

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
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              const Offset begin = Offset(0, 1);
              const Offset end = Offset.zero;

              final Tween<Offset> tween = Tween(begin: begin, end: end);
              final CurvedAnimation curvedAnimation = CurvedAnimation(
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

  Future<void> beginLoad() async {
    if (FirebaseAuth.instance.currentUser == null) {
      animationController.dispose();
      Navigator.pop(context);
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const Loginpage()));
      return;
    }
    await firestore_manager.loadData().then((_) => pushMain(context));
  }

  @override
  Widget build(BuildContext context) {
    animationController.forward();

    const double size = 250;

    WidgetsBinding.instance.addPostFrameCallback((_) => beginLoad());

    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.black, Color.fromARGB(255, 14, 14, 14)],
            ),
          ),
          child: AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, __) => Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                    colors: theming.gradientColors,
                  ).createShader(
                    Rect.fromCenter(
                      center: bounds.center,
                      width: size * animation.value,
                      height: size * animation.value,
                    ),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: size * animation.value,
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
