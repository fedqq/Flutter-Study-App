import 'dart:math';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyappcs/state_managers/exporter.dart' as exporter;
import 'package:studyappcs/state_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/state_managers/statistics.dart' as stats;
import 'package:studyappcs/state_managers/tests_manager.dart' as tests_manager;
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/states/topic.dart';
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

    firestore_manager.goal = result;

    setState(() => stats.dailyGoal = int.parse(result));
  }

  void editUserName() async {
    String name = await singleInputDialog(
      context,
      'Change Username',
      Input(
        name: 'Username',
        value: stats.userName,
      ),
    );
    if (name == '') return;
    firestore_manager.username = name;
    setState(() => stats.userName = name);
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
      );

  void chooseAccentColor() async {
    Color col = await showColorPicker(context, stats.color) ?? Colors.black;
    if (col == Colors.black) return;
    stats.color = col;
    firestore_manager.color = col.value;
  }

  double calculateLearnedPercentage() {
    var a = totalAndLearned();
    return a[1] / a[0];
  }

  List<int> totalAndLearned() {
    int total = 0;
    int learned = 0;
    for (Subject subject in firestore_manager.subjectsList) {
      for (Topic topic in subject.topics) {
        total += topic.cards.length;
        learned += topic.cards.where((a) => a.learned).length;
      }
    }
    return [total, learned];
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(
          Durations.extralong1,
          () async {
            if (stats.userName == '') {
              if (showingNameInput) return;

              showingNameInput = true;
              Future<String?> res =
                  singleInputDialog(context, 'Set User Name', Input(name: 'Name'), cancellable: false);
              String name = await res ?? '';
              setState(() => stats.userName = name);
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

      List<Test> pastTests = tests_manager.pastTests
        ..sort((Test a, Test b) => fromString(a.date).compareTo(fromString(b.date)));
      int sum = 0;
      pastTests.sublist(0, min(10, pastTests.length)).forEach((Test element) => sum += element.percentage);
      return sum / 10;
    }

    double getAllAverage() {
      List<Test> tests = tests_manager.pastTests;
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
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(onPressed: showThemeOptions, icon: const Icon(Icons.settings_rounded)),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 46, 16, 16),
            children: [
              FittedBox(
                fit: BoxFit.fitHeight,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Hello ${stats.userName}',
                        style: theme.displayLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Text(
                        'Today you have studied ${stats.getTodayStudied()} cards out of ${stats.dailyGoal}',
                        style: theme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.all(8),
                      elevation: elevation,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text('  ${stats.calculateStreak()}🔥', textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        elevation: elevation,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildText(
                                '${firestore_manager.tasksList.where((a) => a.dueDate == DateUtils.dateOnly(DateTime.now())).length} due today',
                              ),
                              buildText(
                                '${firestore_manager.tasksList.where((a) => a.dueDate.compareTo(DateUtils.dateOnly(DateTime.now())) > 0).length} overdue',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Card(
                margin: const EdgeInsets.all(8),
                elevation: elevation,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: StudiedChart(animValue: animation.value),
                  ),
                ),
              ),
              if (tests_manager.pastTests.isNotEmpty)
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: elevation,
                  child: Column(
                    children: [
                      buildText(
                        'Average 10 test percentages: ${getRecentAverage()}% (${getRecentAverage() - getAllAverage() >= 0 ? '+' : ''}${getRecentAverage() - getAllAverage()}%)',
                      ),
                      buildText('Average total test percentages: ${getAllAverage()}%'),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        elevation: elevation,
                        child: Center(
                          child: SizedBox.expand(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 10,
                                value: calculateLearnedPercentage() * animation.value,
                                backgroundColor: Colors.black,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        elevation: elevation,
                        child: Center(
                          child: Text(
                            'You have\nlearned ${totalAndLearned()[1]}\nout of ${totalAndLearned()[0]}\ncards',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                            exporter.printEverything(widget.subjects);
                          },
                        ),
                      ],
                    ),
                  ),
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
                      child:
                          FilledButton(onPressed: useDeviceAccentColor, child: const Text("Use Device Accent Color")),
                    ),
                  ),
                  InkWell(
                    onTap: chooseAccentColor,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: stats.color, shape: BoxShape.circle),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.edit_rounded),
                      ),
                    ),
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
                    value: stats.lightness,
                    onChanged: (b) {
                      stats.lightness = b;
                      firestore_manager.lightness = b;
                    },
                  ),
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
    stats.color = color ?? Colors.red;
    firestore_manager.color = stats.color.value;
  }
}
