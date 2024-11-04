// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/data_managers/firestore_manager.dart';
import 'package:studyappcs/data_managers/tests_manager.dart' as tests_manager;
import 'package:studyappcs/pages/results_page.dart';
import 'package:studyappcs/states/test.dart';
import 'package:window_rounded_corners/window_rounded_corners.dart';

class AllTestsPage extends StatefulWidget {
  const AllTestsPage({super.key, this.area = ''});
  final String area;

  @override
  State<AllTestsPage> createState() => _AllTestsPageState();
}

class _AllTestsPageState extends State<AllTestsPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  //Open the results page of the test found at index.
  void openTestPage(BuildContext context, int index) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsPage(test: pastTests[index], editable: false),
        ),
      );

  BorderRadius getRadius(int index) {
    final tests = tests_manager.testsFromArea(widget.area).reversed.toList();
    var top = WindowCorners.getCorners().topLeft + 16;
    var bottom = WindowCorners.getCorners().topLeft + 16;

    final area = tests[index].area;

    if (index != 0) {
      if (area == tests[index - 1].area) {
        top = 2;
      }
    }

    if (index != tests.length - 1) {
      if (area == tests[index + 1].area) {
        bottom = 2;
      }
    }

    final t = Radius.circular(top);
    final b = Radius.circular(bottom);

    return BorderRadius.only(topLeft: t, topRight: t, bottomLeft: b, bottomRight: b);
  }

  EdgeInsets getMargin(int index) {
    final tests = tests_manager.testsFromArea(widget.area).reversed.toList();
    var top = 8.0;
    var bottom = 8.0;

    final area = tests[index].area;

    if (index != 0 && area == tests[index - 1].area) {
      top = 2;
    }

    if (index != tests.length - 1 && area == tests[index + 1].area) {
      bottom = 2;
    }

    return EdgeInsets.fromLTRB(8, top, 8, bottom);
  }

  AppBar buildAppBar() => AppBar(title: Text('Past Tests (${firestore_manager.pastTests.length})'), centerTitle: true);

  Widget buildTestWidget(Test test, int index) => Card(
        elevation: 1,
        margin: getMargin(index),
        shape: RoundedRectangleBorder(borderRadius: getRadius(index)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(test.area, style: Theme.of(context).textTheme.titleMedium),
              Text(test.date),
            ],
          ),
        ),
      );

  Widget buildBody() {
    final tests = tests_manager.testsFromArea(widget.area).reversed.toList();

    return ListView.builder(
      itemCount: tests.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () => openTestPage(context, index),
        child: buildTestWidget(tests[tests.length - index - 1], index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
      );
}
