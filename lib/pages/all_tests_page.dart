// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
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
          builder: (_) => ResultsPage(test: tests_manager.pastTests[index], editable: false),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var tests = <Test>[];

    tests = tests_manager.testsFromArea(widget.area).reversed.toList();

    controller.forward();

    BorderRadius getRadius(int index) {
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

    return Scaffold(
      appBar: AppBar(title: Text('Past Tests (${tests_manager.pastTests.length})'), centerTitle: true),
      body: ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () => openTestPage(context, index),
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, __) => Card(
              elevation: 1,
              margin: getMargin(index),
              shape: RoundedRectangleBorder(borderRadius: getRadius(index)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      tests[index].area,
                      style: Theme.of(context).textTheme.titleMedium,
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
