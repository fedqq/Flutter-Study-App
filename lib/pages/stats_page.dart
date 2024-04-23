import 'package:flutter/material.dart';
import 'package:flutter_application_1/state_managers/statistics.dart';
import 'package:flutter_application_1/reused_widgets/input_dialogs.dart';
import 'package:flutter_application_1/utils.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    if (Statistics.userName == '') {
      Future.delayed(Durations.extralong1, () async {
        if (showingNameInput) return;

        showingNameInput = true;
        Future<String?> res = showInputDialog(context, 'Set User Name', 'Name', cancellable: false);
        String name = await res ?? '';
        showingNameInput = false;
        setState(() {
          Statistics.userName = name;
        });
      });
    }

    controller.forward();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, __) => Container(
                margin: const EdgeInsets.all(100.0),
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Theming.coloredGradient.colors[0].withAlpha((120 * animation.value).toInt()),
                    blurRadius: 60 * animation.value,
                  )
                ]),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Hello ${Statistics.userName}',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Text('Today you have studied ${Statistics.getTodayStudied()} cards out of ${Statistics.dailyGoal}')
          ],
        ),
      ),
    );
  }
}
