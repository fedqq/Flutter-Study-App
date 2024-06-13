// ignore: unused_import
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:studyappcs/pages/calendar_page.dart';
import 'package:studyappcs/pages/splash_screen.dart';
import 'package:studyappcs/pages/stats_page.dart';
import 'package:studyappcs/pages/subjects_page.dart';
import 'package:studyappcs/state_managers/sql_data_manager.dart';
import 'package:studyappcs/state_managers/statistics.dart';
import 'package:studyappcs/state_managers/tests_manager.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/utils/snackbar.dart';
import 'package:window_rounded_corners/window_rounded_corners.dart';

// ignore: constant_identifier_names
const CLEAR = false;

void main() {
  sqfliteFfiInit();
  if (Platform.isWindows) {
    databaseFactory = databaseFactoryFfi;
  }
  WidgetsFlutterBinding.ensureInitialized();
  WindowCorners.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FutureBuilder<Color?>(
      future: DynamicColorPlugin.getAccentColor(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final color = snapshot.data;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Study App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: color ?? Colors.accents[0]),
              brightness: Brightness.dark,
              useMaterial3: true,
              fontFamily: 'Product Sans',
            ),
            initialRoute: '/splash',
            routes: {'/splash': (context) => const SplashScreen()},
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study App',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Product Sans',
      ),
      initialRoute: '/splash',
      routes: {'/splash': (context) => const SplashScreen()},
    );

    return DynamicColorBuilder(
      builder: (light, dark) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Study App',
          theme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            fontFamily: 'Product Sans',
            colorScheme: dark,
          ),
          initialRoute: '/splash',
          routes: {'/splash': (context) => const SplashScreen()},
        );
      },
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
    loadData();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  Future loadData() async {
    List<Subject> subjectsRes = [];
    List<Task> tasksRes = [];
    List<Task> completedTasksRes = [];
    subjectsRes = await SQLManager.loadSubjects();
    completedTasksRes = await SQLManager.loadCompletedTasks();
    tasksRes = await SQLManager.loadTasks();

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
    await SQLManager.saveData(subjects, tasks, completedTasks);
    StudyStatistics.saveData();
    TestsManager.saveData();
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

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      StatsPage(saveCallback: saveData, loadCallback: loadData, subjects: subjects),
      SubjectsPage(subjects: subjects),
      CalendarPage(tasks: tasks, completedTasks: completedTasks),
    ];

    if (CLEAR) {
      SQLManager.clearAll();
    }

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
