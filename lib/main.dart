// ignore: unused_import
import 'dart:developer' as developer;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:studyapp/pages/calendar_page.dart';
import 'package:studyapp/pages/splash_screen.dart';
import 'package:studyapp/pages/stats_page.dart';
import 'package:studyapp/pages/subjects_page.dart';
import 'package:studyapp/state_managers/data_manager.dart';
import 'package:studyapp/state_managers/statistics.dart';
import 'package:studyapp/state_managers/tests_manager.dart';
import 'package:studyapp/states/subject.dart';
import 'package:studyapp/states/task.dart';
import 'package:studyapp/utils/snackbar.dart';
import 'package:window_rounded_corners/window_rounded_corners.dart';

// ignore: constant_identifier_names
const CLEAR = false;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WindowCorners.init();

    return DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Study App',
        theme: ThemeData(
          colorScheme: darkDynamic,
          useMaterial3: true,
          fontFamily: 'Product Sans',
        ),
        initialRoute: '/splash',
        routes: {'/splash': (context) => const SplashScreen()},
      );
    });
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
    SaveDataManager.saveData(subjects, tasks, completedTasks);
    TestsManager.saveData();
    StudyStatistics.saveData();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    loadData();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void loadData() async {
    List<Subject> subjectsRes = [];
    List<Task> tasksRes = [];
    List<Task> completedTasksRes = [];
    subjectsRes = await SaveDataManager.loadSubjects();
    tasksRes = await SaveDataManager.loadTasks();
    completedTasksRes = await SaveDataManager.loadCompletedTasks();

    StudyStatistics.load();
    TestsManager.loadData();

    try {} catch (e) {
      developer.log(e.toString());
      snackbar('Error occurred while loading data');
    }

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

  void saveData() {
    SaveDataManager.saveData(subjects, tasks, completedTasks);
    StudyStatistics.saveData();
    TestsManager.saveData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    saveData();
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
      SaveDataManager.clearAll();
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
