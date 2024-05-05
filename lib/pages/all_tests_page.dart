import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/results_page.dart';
import 'package:flutter_application_1/state_managers/tests_manager.dart';
import 'package:flutter_application_1/states/test.dart';
import 'package:flutter_application_1/utils/gradient_widgets.dart';
import 'package:flutter_application_1/utils/theming.dart';

class AllTestsPage extends StatefulWidget {
  final String area;
  const AllTestsPage({super.key, this.area = ''});

  @override
  State<AllTestsPage> createState() => _AllTestsPageState();
}

class _AllTestsPageState extends State<AllTestsPage> {
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

    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () => openTestPage(context, index),
          child: GradientOutline(
            gradient: Theming.grayGradient,
            innerPadding: 20,
            child: Row(
              children: [
                Text(
                  tests[index].area,
                  style: theme.titleLarge!.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text(tests[index].date),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
