import 'dart:math';

import 'package:flutter/material.dart';
import 'package:studyapp/state_managers/data_manager.dart';
import 'package:studyapp/state_managers/exporter.dart';
import 'package:studyapp/state_managers/statistics.dart';
import 'package:studyapp/state_managers/tests_manager.dart';
import 'package:studyapp/states/subject.dart';
import 'package:studyapp/states/test.dart';
import 'package:studyapp/utils/expandable_fab.dart';
import 'package:studyapp/utils/input_dialogs.dart';
import 'package:studyapp/widgets/studied_chart.dart';

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

  ExFabController exFabController = ExFabController();

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

  void setDailyGoal() async {
    String result = await singleInputDialog(
          context,
          'Choose Daily Goal',
          Input(name: 'Goal', numerical: true, validate: (str) => (int.tryParse(str) ?? 0) > 0),
        ) ??
        '';
    if (result == '') return;
    setState(() => StudyStatistics.dailyGoal = int.parse(result));
  }

  void editUserName() async {
    String name = await singleInputDialog(
          context,
          'Change Username',
          Input(
            name: 'Username',
            initialValue: StudyStatistics.userName,
          ),
        ) ??
        '';
    if (name == '') return;
    setState(() {
      StudyStatistics.userName = name;
    });
  }

  Widget buildButton(String text, void Function() callback) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: FilledButton.tonal(
          onPressed: callback,
          child: Text(text),
        ),
      );

  Widget buildText(String s) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          s,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );

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

    controller.forward();

    ExpandableFab fab = ExpandableFab(
      controller: exFabController,
      children: [
        ActionButton(onPressed: editUserName, icon: const Icon(Icons.person_rounded), name: 'Change Username'),
        ActionButton(onPressed: setDailyGoal, icon: const Icon(Icons.flag_rounded), name: 'Change Daily Goal'),
      ],
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
        total += element.totalAmount;
      }
      return total / length;
    }

    TextTheme theme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        double elevation = 2 * animation.value;
        double margin = 18 - 10 * animation.value;

        return Scaffold(
          floatingActionButton: fab,
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
                margin: EdgeInsets.all(margin),
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
                margin: EdgeInsets.all(margin),
                elevation: elevation,
                child: Column(
                  children: [
                    buildText('You are currently on a ${StudyStatistics.calculateStreak()} day streak'),
                    buildText('Your highest streak was ${StudyStatistics.maxStreak} days'),
                  ],
                ),
              ),
              SizedBox(
                height: 80,
                child: Card(
                  margin: EdgeInsets.all(margin),
                  elevation: elevation,
                  child: ListView(
                    padding: const EdgeInsets.all(12.0),
                    scrollDirection: Axis.horizontal,
                    children: [
                      buildButton('Export Data', () {
                        widget.saveCallback();
                        SaveDataManager.exportEverything();
                      }),
                      buildButton('Import Data', () => SaveDataManager.importEverything(widget.loadCallback, context)),
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
              if (TestsManager.pastTests.isNotEmpty)
                Card(
                  margin: EdgeInsets.all(margin),
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
}
