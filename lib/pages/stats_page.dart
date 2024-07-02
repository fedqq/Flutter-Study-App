import 'dart:math';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyappcs/data_managers/exporter.dart' as exporter;
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/data_managers/tests_manager.dart' as tests_manager;
import 'package:studyappcs/data_managers/user_data.dart' as user_data;
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
    controller = AnimationController(vsync: this, value: 0, duration: const Duration(seconds: 2));

    animation = CurvedAnimation(
      curve: Curves.easeOutCirc,
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

    setState(() => user_data.dailyGoal = int.parse(result));
  }

  void editUserName() async {
    String name = await singleInputDialog(
      context,
      'Change Username',
      Input(
        name: 'Username',
        value: user_data.userName,
      ),
    );
    if (name == '') return;
    firestore_manager.username = name;
    setState(() => user_data.userName = name);
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
    Color col = await showColorPicker(context, user_data.color) ?? Colors.black;
    if (col == Colors.black) return;
    user_data.color = col;
    firestore_manager.color = col.value;
  }

  double calculateLearnedPercentage() {
    var a = totalAndLearned();
    return a[0] == 0 ? 0 : a[1] / a[0];
  }

  List<int> totalAndLearned() {
    int total = 0;
    int learned = 0;
    for (Subject subject in firestore_manager.subjectsList) {
      total += subject.total;
      learned += subject.learned;
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
            if (user_data.userName == '') {
              if (showingNameInput) return;

              showingNameInput = true;
              Future<String?> res =
                  singleInputDialog(context, 'Set User Name', Input(name: 'Name'), cancellable: false);
              String name = await res ?? '';
              setState(() => user_data.userName = name);
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

    controller.forward();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, __) {
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
          body: Opacity(
            opacity: animation.value,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 46, 16, 16),
              children: [
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Hello ${user_data.userName}',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Text(
                          'Today you have studied ${user_data.getTodayStudied()} cards out of ${user_data.dailyGoal}',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(8),
                      elevation: 2,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text('  ${user_data.calculateStreak()}🔥', textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 1,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        elevation: 2,
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
                  ].map((a) => Expanded(child: a)).toList(),
                ),
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
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
                    elevation: 2,
                    child: Column(
                      children: [
                        buildText(
                          'Last 10 average test scores: ${getRecentAverage()}% (${getRecentAverage() - getAllAverage() >= 0 ? '+' : ''}${getRecentAverage() - getAllAverage()}%)',
                        ),
                        buildText('Overall average scores: ${getAllAverage()}%'),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    SizedBox.expand(
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
                    Text(
                      'You have\nlearned ${totalAndLearned()[1]}\nout of \n${totalAndLearned()[0]}cards',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ]
                      .map(
                        (a) => Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Card(margin: const EdgeInsets.all(8), child: Center(child: a)),
                          ),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(
                  height: 80,
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
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
              ].map((a) => ScaleTransition(scale: animation, child: a)).toList(),
            ),
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
            TextButton.icon(
              onPressed: editUserName,
              label: const Row(
                children: [Text("Edit Username")],
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              iconAlignment: IconAlignment.end,
            ),
            TextButton.icon(
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
            TextButton.icon(
              onPressed: editDailyGoal,
              label: const Row(
                children: [Text("Edit Daily Goal")],
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              iconAlignment: IconAlignment.end,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton(onPressed: useDeviceAccentColor, child: const Text("Use Device Accent Color")),
                  ),
                ),
                InkWell(
                  onTap: chooseAccentColor,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: user_data.color, shape: BoxShape.circle),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.edit_rounded),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Light Mode"),
                Switch(
                  value: user_data.lightness,
                  onChanged: (b) {
                    user_data.lightness = b;
                    firestore_manager.lightness = b;
                  },
                ),
              ],
            ),
          ].map((a) => Padding(padding: const EdgeInsets.all(8), child: a)).toList(),
        );
      },
    );
  }

  void useDeviceAccentColor() async {
    Color? color = (await DynamicColorPlugin.getCorePalette())?.toColorScheme().primary;
    user_data.color = color ?? Colors.red;
    firestore_manager.color = user_data.color.value;
  }
}
