// ignore: unused_import
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/firebase_options.dart';
import 'package:studyappcs/pages/calendar_page.dart';
import 'package:studyappcs/pages/splash_screen.dart';
import 'package:studyappcs/pages/stats_page.dart';
import 'package:studyappcs/pages/subjects_page.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/data_managers/user_data.dart' as user_data;
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/utils/utils.dart';
import 'package:window_rounded_corners/window_rounded_corners.dart';

// ignore: constant_identifier_names
const CLEAR = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WindowCorners.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    user_data.updateTheme = setState;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study App',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Product Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: user_data.color,
          brightness: user_data.lightness ? Brightness.light : Brightness.dark,
        ),
      ),
      initialRoute: '/splash',
      routes: {'/splash': (context) => const SplashScreen()},
    );
  }
}

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key, required this.title});
  final String title;

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> with WidgetsBindingObserver {
  List<Subject> subjects = [];
  List<Task> tasks = [];
  List<Task> completedTasks = [];
  int selectedDest = 0;
  PageController pageController = PageController();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    loadData();
    super.initState();
  }

  Future loadData() async {
    List<Subject> subjectsRes = [];
    List<Task> tasksRes = [];
    List<Task> completedTasksRes = [];

    subjectsRes = firestore_manager.subjectsList;
    tasksRes = firestore_manager.tasksList;
    completedTasksRes = firestore_manager.compTasksList;

    setState(() {
      subjects = subjectsRes;
      tasks = tasksRes;
      completedTasks = completedTasksRes;
    });
  }

  void snackbar(String s) => simpleSnackBar(context, s);

  void pageChanged(int index) {
    setState(() {
      selectedDest = index;
    });
  }

  Future saveData() async {
    await firestore_manager.saveData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    await saveData();
    super.didChangeAppLifecycleState(state);
  }

  void selectDestination(int index) {
    setState(() {
      selectedDest = index;
      pageController.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  Future authlogin({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      snackbar('Succesfully logged in. ');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        snackbar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        snackbar('Wrong password provided for that user.');
      } else {
        snackbar(e.message ?? '');
      }
    } catch (e) {
      snackbar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      StatsPage(saveCallback: saveData, loadCallback: loadData, subjects: subjects),
      SubjectsPage(subjects: subjects),
      CalendarPage(tasks: tasks, completedTasks: completedTasks),
    ];

    double left = WindowCorners.getCorners().bottomLeft - 8;
    double right = WindowCorners.getCorners().bottomRight - 8;

    Scaffold scaffold = Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(left),
            bottomRight: Radius.circular(right),
            topLeft: Radius.circular(left),
            topRight: Radius.circular(right),
          ),
          child: BottomAppBar(
            height: 70,
            child: NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              indicatorColor: Theme.of(context).colorScheme.primaryContainer,
              selectedIndex: selectedDest,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  label: "Statistics",
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                ),
                NavigationDestination(
                  icon: Icon(Icons.school),
                  label: "Study",
                  selectedIcon: Icon(Icons.school_rounded),
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  label: "Calendar",
                  selectedIcon: Icon(Icons.calendar_today_rounded),
                ),
              ],
              onDestinationSelected: selectDestination,
            ),
          ),
        ),
      ),
      body: PageView(controller: pageController, onPageChanged: pageChanged, padEnds: false, children: pages),
    );

    return scaffold;
  }
}
