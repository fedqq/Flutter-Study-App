import 'package:flutter/material.dart';
import 'package:flutter_application_1/state_managers/tests_manager.dart';

class AllTestsPage extends StatefulWidget {
  const AllTestsPage({super.key});

  @override
  State<AllTestsPage> createState() => _AllTestsPageState();
}

class _AllTestsPageState extends State<AllTestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: TestsManager.pastTests.length,
        itemBuilder: (context, index) =>
            Text('${TestsManager.pastTests[index].area} - ${TestsManager.pastTests[index].date}'),
      ),
    );
  }
}
