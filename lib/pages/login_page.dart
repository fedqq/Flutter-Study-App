// ignore_for_file: always_specify_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/main.dart';
import 'package:studyappcs/utils/page_transition.dart';
import 'package:studyappcs/utils/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  Future<void> proceed() async {
    await firestore_manager.loadData();
    setState(() => loading = false);
    await pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      () => NavigationPage(title: 'Study Help App', username: username, firstLogin: register),
    );
  }

  Future<void> submit() async {
    setState(() => loading = true);
    final a = await (register ? _signupUser(email, password, username) : _authUser(email, password));
    if (a == null) {
      await proceed();
      return;
    } else {
      snackbar(a);
    }

    setState(() => loading = false);
  }

  Widget buildActionButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: FilledButton(onPressed: submit, child: const Text('Submit'))),
          const SizedBox(width: 20),
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => register = !register),
              child: Text(!register ? 'Sign Up' : 'Log In'),
            ),
          ),
        ],
      );

  Widget buildLoader() => const Center(
        child: CircularProgressIndicator(
          strokeCap: StrokeCap.round,
          strokeWidth: 7,
        ),
      );

  Widget buildEmailField() => Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          onChanged: (v) => email = v,
          decoration: const InputDecoration.collapsed(hintText: 'E-Mail'),
        ),
      );

  Widget buildPasswordField() => Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          onChanged: (v) => password = v,
          decoration: const InputDecoration.collapsed(hintText: 'Password'),
          obscureText: true,
        ),
      );

  Widget buildUsernameField() => Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          onChanged: (v) => username = v,
          decoration: const InputDecoration.collapsed(hintText: 'Username'),
        ),
      );

  String currentValue() => register ? 'Sign up' : 'Log in';

  Widget buildAuthForm() => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    duration: Durations.short2,
                    child: Text(
                      currentValue(),
                      style: Theme.of(context).textTheme.displaySmall,
                      key: ValueKey<String>(currentValue()),
                    ),
                  ),
                  buildEmailField(),
                  const SizedBox(height: 20),
                  buildPasswordField(),
                  const SizedBox(height: 20),
                  if (register) ...[
                    buildUsernameField(),
                    const SizedBox(height: 20),
                  ],
                  buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Study App', style: Theme.of(context).textTheme.displayLarge),
            ),
            if (loading) buildLoader() else buildAuthForm(),
            const Spacer(),
          ],
        ),
      );
}
