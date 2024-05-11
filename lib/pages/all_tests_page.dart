import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/results_page.dart';
import 'package:flutter_application_1/state_managers/tests_manager.dart';
import 'package:flutter_application_1/states/test.dart';

class AllTestsPage extends StatefulWidget {
  final String area;
  const AllTestsPage({super.key, this.area = ''});

  @override
  State<AllTestsPage> createState() => _AllTestsPageState();
}

class _AllTestsPageState extends State<AllTestsPage> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(vsync: this, value: 0, duration: Durations.extralong4);

    animation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: controller,
    );

    super.initState();
  }

  void openTestPage(BuildContext context, int index) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsPage(test: TestsManager.pastTests[index], editable: false),
        ),
      );

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    List<Test> tests = [];

    tests = TestsManager.testsFromArea(widget.area);

    controller.forward();

    return Scaffold(
      appBar: AppBar(title: Text('Past Tests (${TestsManager.pastTests.length})')),
      body: ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () => openTestPage(context, index),
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, __) => Card(
              margin: const EdgeInsets.all(8.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      tests[index].area,
                      style: theme.titleMedium!,
                    ),
                    Text(tests[index].date),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
