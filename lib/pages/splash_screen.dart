// ignore_for_file: always_specify_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/main.dart';
import 'package:studyappcs/pages/login_page.dart';
import 'package:studyappcs/utils/page_transition.dart';

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
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    animation = CurvedAnimation(
      curve: Curves.easeOutCirc,
      parent: animationController,
    );
    super.initState();
  }

  void pushMain(BuildContext context) {
    Future.delayed(
      Durations.long1,
      () => pushReplacement(context, () => const NavigationPage(title: 'Study Help App', firstLogin: false)),
    );
  }

  Future<void> beginLoad() async {
    if (FirebaseAuth.instance.currentUser == null) {
      animationController.dispose();
      await pushReplacement(context, () => const LoginPage());
      return;
    }
    await firestore_manager.loadData().then((_) => pushMain(context));
  }

  @override
  Widget build(BuildContext context) {
    animationController.forward();

    const size = 250.0;

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
          child: ScaleTransition(
            scale: animation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    tileMode: TileMode.repeated,
                    colors: [Colors.deepPurple, Colors.blue[900] ?? Colors.blue],
                  ).createShader(
                    Rect.fromCenter(
                      center: bounds.center,
                      width: size,
                      height: size,
                    ),
                  ),
                  child: const Icon(Icons.school_rounded, size: size),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
