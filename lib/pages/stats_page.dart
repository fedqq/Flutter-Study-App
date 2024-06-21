import 'dart:math';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyappcs/state_managers/exporter.dart';
import 'package:studyappcs/state_managers/firestore_manager.dart';
import 'package:studyappcs/state_managers/statistics.dart';
import 'package:studyappcs/state_managers/tests_manager.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/widgets/studied_chart.dart';

class StatsPage extends StatefulWidget {
  final void Function() saveCallback;
  final void Function() loadCallback;
  final List<Subject> subjects;
  const StatsPage({super.key, required this.saveCallback, required this.loadCallback, required this.subjects});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with SingleTickerProviderStateMixin {
  bool showingNameInput = false;
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this, value: 0, duration: Durations.long3);

    animation = CurvedAnimation(
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOutQuad,
      parent: controller,
    );
    super.initState();
  }

  void editDailyGoal() async {
    String result = await singleInputDialog(
      context,
      'Choose Daily Goal',
      Input(name: 'Goal', numerical: true, validate: (str) => (int.tryParse(str) ?? 0) > 0),
    );
    if (result == '') return;

    FirestoreManager.goal = result;

    setState(() => StudyStatistics.dailyGoal = int.parse(result));
  }

  void editUserName() async {
    String name = await singleInputDialog(
      context,
      'Change Username',
      Input(
        name: 'Username',
        value: StudyStatistics.userName,
      ),
    );
    if (name == '') return;
    FirestoreManager.username = name;
    setState(() => StudyStatistics.userName = name);
  }

  Widget buildButton(String text, void Function() callback) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: FilledButton.tonal(
            onPressed: callback,
            child: Text(text),
          ),
        ),
      );

  Widget buildText(String s) => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          s,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );

  void chooseAccentColor() async {
    Color col = await showColorPicker(context, StudyStatistics.color) ?? Colors.black;
    if (col == Colors.black) return;
    StudyStatistics.color = col;
    FirestoreManager.color = col.value;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(
          Durations.extralong1,
          () async {
            if (StudyStatistics.userName == '') {
              if (showingNameInput) return;

              showingNameInput = true;
              Future<String?> res =
                  singleInputDialog(context, 'Set User Name', Input(name: 'Name'), cancellable: false);
              String name = await res ?? '';
              setState(() => StudyStatistics.userName = name);
              showingNameInput = false;
            }
          },
        );
      },
    );

    double getRecentAverage() {
      DateTime fromString(String s) {
        var [day, month, year] = s.split('/');

        return DateTime(int.parse(year), int.parse(month), int.parse(day));
      }

      List<Test> pastTests = TestsManager.pastTests;
      pastTests.sort((Test a, Test b) => fromString(a.date).compareTo(fromString(b.date)));
      int sum = 0;
      pastTests.sublist(0, min(10, pastTests.length)).forEach((Test element) => sum += element.percentage);
      return sum / 10;
    }

    double getAllAverage() {
      List<Test> tests = TestsManager.pastTests;
      int total = 0;
      int length = tests.length;
      for (var element in tests) {
        total += element.percentage;
      }
      return total / length;
    }

    TextTheme theme = Theme.of(context).textTheme;

    controller.forward();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, __) {
        double elevation = 2 * animation.value;

        return Scaffold(
          appBar: AppBar(
            actions: [IconButton(onPressed: showThemeOptions, icon: const Icon(Icons.settings_rounded))],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              FittedBox(
                fit: BoxFit.fitHeight,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Hello ${StudyStatistics.userName}', style: theme.displaySmall),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Text(
                        'Today you have studied ${StudyStatistics.getTodayStudied()} cards out of ${StudyStatistics.dailyGoal}',
                        style: theme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.all(8),
                elevation: elevation,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(52, 20, 52, 50),
                    child: StudiedChart(animValue: animation.value),
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(8),
                elevation: elevation,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      buildText('You are currently on a ${StudyStatistics.calculateStreak()} day streak'),
                      buildText('Your highest streak was ${StudyStatistics.maxStreak} days'),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 80,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  elevation: elevation,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        //TODO: Find another button to put here
                        buildButton(
                          'Data to PDF',
                          () {
                            widget.saveCallback();
                            Exporter.printEverything(widget.subjects);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (TestsManager.pastTests.isNotEmpty)
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: elevation,
                  child: Column(
                    children: [
                      buildText(
                          'Average 10 test percentages: ${getRecentAverage()}% (${getRecentAverage() - getAllAverage() >= 0 ? '+' : ''}${(getRecentAverage() - getAllAverage())}%)'),
                      buildText('Average total test percentages: ${getAllAverage()}%'),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void showThemeOptions() {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: editUserName,
                label: const Row(
                  children: [Text("Edit Username")],
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                iconAlignment: IconAlignment.end,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  SystemNavigator.pop();
                },
                label: const Row(
                  children: [Text("Sign Out (Closes the app)")],
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                iconAlignment: IconAlignment.end,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: editDailyGoal,
                label: const Row(
                  children: [Text("Edit Daily Goal")],
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                iconAlignment: IconAlignment.end,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton(onPressed: useDeviceAccentColor, child: const Text("Use Device Accent Color")),
                  )),
                  InkWell(
                    onTap: chooseAccentColor,
                    child: Container(
                        decoration: BoxDecoration(color: StudyStatistics.color, shape: BoxShape.circle),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.edit_rounded),
                        )),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Light Mode"),
                  Switch(
                      value: StudyStatistics.lightness,
                      onChanged: (b) {
                        StudyStatistics.lightness = b;
                        FirestoreManager.lightness = b;
                      })
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void useDeviceAccentColor() async {
    Color? color = (await DynamicColorPlugin.getCorePalette())?.toColorScheme().primary;
    StudyStatistics.color = color ?? Colors.red;
    FirestoreManager.color = StudyStatistics.color.value;
  }
}
