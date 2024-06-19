import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:studyappcs/main.dart';
import 'package:studyappcs/state_managers/firestore_manager.dart';
import 'package:studyappcs/utils/utils.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  void snackbar(String s) => simpleSnackBar(context, s);

  Future<String?> _authUser(LoginData data) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message ?? '';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Study App CS',
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () async {
        await FirestoreManager.loadData();
        Navigator.pushReplacement(
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
      onRecoverPassword: (_) => null,
    );
  }
}
