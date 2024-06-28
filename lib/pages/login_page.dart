import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/main.dart';
import 'package:studyappcs/utils/utils.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool loading = false;
  bool register = false;
  String email = '';
  String password = '';
  String username = '';
  void snackbar(String s) => simpleSnackBar(context, s);

  Future<String?> _authUser(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
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

  Future<String?> _signupUser(String email, String password, String username) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      firestore_manager.username = username;
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'An account with this email already exists.';
      } else if (e.code == 'invalid-email') {
        return 'Please enter a valid e-mail.';
      } else if (e.code == 'operation-not-allowed') {
        return 'An unknown error occured. Please try again later.';
      } else if (e.code == 'weak-password') {
        return 'Password too weak.';
      } else {
        return e.message ?? '';
      }
    } catch (e) {
      return e.toString();
    }
  }

  void close() async {
    await firestore_manager.loadData();
    setState(() => loading = false);
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
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
  }

  void submit() async {
    setState(() => loading = true);
    String? a = await (register ? _signupUser(email, password, username) : _authUser(email, password));
    if (a == null) {
      close();
      return;
    } else {
      snackbar(a);
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          loading
              ? const Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round, strokeWidth: 7))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Log in', style: Theme.of(context).textTheme.displayMedium),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                onChanged: (v) => email = v,
                                decoration: const InputDecoration.collapsed(hintText: 'E-Mail'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                onChanged: (v) => password = v,
                                decoration: const InputDecoration.collapsed(hintText: 'Password'),
                                obscureText: true,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (register) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  onChanged: (v) => username = v,
                                  decoration: const InputDecoration.collapsed(hintText: 'Username'),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: FilledButton(onPressed: submit, child: const Text('Submit'))),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: FilledButton.tonal(
                                    onPressed: () => setState(() => register = !register),
                                    child: Text(!register ? 'Sign Up' : 'Log In'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
