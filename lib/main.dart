// ignore_for_file: use_build_context_synchronously

import 'package:flutter_application_1/pages/subjects_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_manager.dart';
import 'package:flutter_application_1/pages/calendar_page.dart';
import 'package:flutter_application_1/states/subject.dart';

import 'package:flutter_application_1/states/task.dart';
import 'package:flutter_application_1/utils.dart';

// ignore: unused_import
import 'dart:developer' as developer;

// ignore: constant_identifier_names
const bool CLEAR = false;

void main() {
  //runApp(MaterialApp(initialRoute: '/home', routes: {
  // '/splash': (context) => const SplashScreen(),
  // '/home': (context) => const MyApp(),
  //}));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study App',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
        indicatorColor: const Color.fromARGB(255, 87, 61, 255),
        fontFamily: 'Inter',
      ),
      home: const MyHomePage(title: 'Study Help App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<Subject> subjects = [];
  List<Task> tasks = [];
  int _selectedDestination = 0;
  bool initialLoaded = false;
  PageController pageController = PageController();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SaveDataManager.saveData(subjects, tasks);
    super.dispose();
  }

  @override
  void initState() {
    loadData();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void loadData() async {
    var subjectsAsync = await SaveDataManager.loadSubjects();
    var tasksAsync = await SaveDataManager.loadTasks();
    setState(() {
      subjects = subjectsAsync;
      tasks = tasksAsync;
    });
    initialLoaded = true;
  }

  void pageChanged(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    SaveDataManager.saveData(subjects, tasks);
    super.didChangeAppLifecycleState(state);
  }

  void selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
      pageController.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    SubjectsPage studyPage = SubjectsPage(subjects: subjects);

    List<Widget> pages = [
      CalendarPage(tasks: tasks),
      studyPage,
      Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => simpleSnackBar(context, 'Testt'),
        ),
      )
    ];
    if (CLEAR) {
      SaveDataManager.clearAll();
    }

    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    HSLColor hslBg = HSLColor.fromColor(bgColor);

    return Stack(
      children: [
        Positioned.fill(
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [bgColor, hslBg.withLightness(hslBg.lightness - 0.03).toColor()])))),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theming.boxShadowColor,
                  spreadRadius: -10,
                  blurRadius: 30,
                )
              ],
            ),
            child: GradientOutline(
              child: NavigationBar(
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                selectedIndex: _selectedDestination,
                indicatorColor: const Color.fromARGB(255, 66, 37, 255),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.calendar_today_rounded), label: "Calendar"),
                  NavigationDestination(icon: Icon(Icons.school_outlined), label: "Study"),
                  NavigationDestination(icon: Icon(Icons.show_chart_rounded), label: "Statistics")
                ],
                backgroundColor: Colors.transparent,
                onDestinationSelected: selectDestination,
              ),
            ),
          ),
          body: PageView(controller: pageController, onPageChanged: pageChanged, padEnds: false, children: pages),
        )
      ],
    );
  }
}
