import 'dart:math';
import 'dart:ui';

import 'package:flutter_application_1/pages/splash_screen.dart';
import 'package:flutter_application_1/pages/stats_page.dart';
import 'package:flutter_application_1/pages/subjects_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/state_managers/data_manager.dart';
import 'package:flutter_application_1/pages/calendar_page.dart';
import 'package:flutter_application_1/state_managers/statistics.dart';
import 'package:flutter_application_1/state_managers/tests_manager.dart';
import 'package:flutter_application_1/states/subject.dart';
import 'package:flutter_application_1/states/task.dart';
import 'package:blobs/blobs.dart';
import 'package:window_rounded_corners/window_rounded_corners.dart';

// ignore: unused_import
import 'dart:developer' as developer;

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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study App',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 33, 150, 243), brightness: Brightness.dark),
        useMaterial3: true,
        fontFamily: 'Product Sans',
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
    var subjectsAsync = await SaveDataManager.loadSubjects();
    var tasksAsync = await SaveDataManager.loadTasks();
    var completedTasksAsync = await SaveDataManager.loadCompletedTasks();
    StudyStatistics.load();
    TestsManager.loadData();

    setState(() {
      subjects = subjectsAsync;
      tasks = tasksAsync;
      completedTasks = completedTasksAsync;
    });
  }

  void pageChanged(int index) {
    setState(() {
      selectedDest = index;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    SaveDataManager.saveData(subjects, tasks, completedTasks);
    StudyStatistics.saveData();
    TestsManager.saveData();
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
      const StatsPage(),
      SubjectsPage(subjects: subjects),
      CalendarPage(tasks: tasks, completedTasks: completedTasks),
    ];

    if (CLEAR) {
      SaveDataManager.clearAll();
    }

    Scaffold scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(WindowCorners.getCorners().bottomLeft),
            bottomRight: Radius.circular(WindowCorners.getCorners().bottomRight),
            topLeft: Radius.circular(WindowCorners.getCorners().bottomLeft),
            topRight: Radius.circular(WindowCorners.getCorners().bottomRight),
          ),
          child: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            shadowColor: Colors.transparent,
            elevation: 10,
            selectedIndex: selectedDest,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                label: "Statistics",
                selectedIcon: Icon(Icons.bar_chart_rounded),
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
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
      body: PageView(controller: pageController, onPageChanged: pageChanged, padEnds: false, children: pages),
    );

    return Stack(
      children: [
        Positioned.fill(child: Container(color: Theme.of(context).scaffoldBackgroundColor)),
        const GrainyBackground(),
        const Positioned.fill(
          child: Opacity(
            opacity: .80,
            child: Image(image: AssetImage('assets/noise.png'), repeat: ImageRepeat.repeat),
          ),
        ),
        scaffold,
      ],
    );
  }
}

class GrainyBackground extends StatelessWidget {
  const GrainyBackground({super.key});

  double getX(double width) => Random().nextInt(width.toInt()).toDouble() % width;

  double getY(double height) => Random().nextInt(height.toInt()).toDouble() % height;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            alignment: Alignment.topLeft,
            children: [
              ...List.generate(
                Random().nextInt(10) + 20,
                (index) {
                  double size = Random().nextInt(600).toDouble();

                  return Positioned(
                    top: getX(constraints.maxHeight) - size / 2,
                    left: getY(constraints.maxWidth) - size / 2,
                    child: Blob.animatedRandom(
                      duration: Durations.short1,
                      styles:
                          BlobStyles(color: Theme.of(context).colorScheme.surfaceTint.withAlpha(Random().nextInt(8))),
                      size: size + 30,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
