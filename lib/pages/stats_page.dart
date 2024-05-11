import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/expandable_fab.dart';
import 'package:flutter_application_1/state_managers/statistics.dart';
import 'package:flutter_application_1/utils/input_dialogs.dart';
import 'package:flutter_application_1/widgets/studied_chart.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

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
          InputType(name: 'Goal', numerical: true, validate: (str) => (int.tryParse(str) ?? 0) > 0),
        ) ??
        '';
    if (result == '') return;
    setState(() => StudyStatistics.dailyGoal = int.parse(result));
  }

  void editUserName() async {
    String name = await singleInputDialog(
          context,
          'Change Username',
          InputType(
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
                  singleInputDialog(context, 'Set User Name', InputType(name: 'Name'), cancellable: false);
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

    return SafeArea(
      child: GestureDetector(
        onTap: () => setState(() => exFabController.close()),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          floatingActionButton: fab,
          body: Column(
            children: [
              AnimatedBuilder(
                animation: animation,
                builder: (context, __) => Container(
                  margin: const EdgeInsets.fromLTRB(80.0, 30, 80, 50),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ImageFiltered(
                      imageFilter:
                          ImageFilter.blur(sigmaX: 8 * (1 - animation.value), sigmaY: 8 * (1 - animation.value)),
                      child: Text(
                        'Hello\n${StudyStatistics.userName}',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge!
                            .copyWith(fontWeight: FontWeight.w800, fontSize: 100),
                      ),
                    ),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Today you have studied ${StudyStatistics.getTodayStudied()}\ncards out of ${StudyStatistics.dailyGoal}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(52, 20, 52, 50),
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (_, __) => StudiedChart(animValue: animation.value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
