import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/day_card.dart';
import 'package:flutter_application_1/states/task.dart';

class CalendarPage extends StatefulWidget {
  final Map<DateTime, List<Task>> dateTasks;
  const CalendarPage({super.key, required this.dateTasks});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) => DayCard(
          date: DateTime.now().add(Duration(days: index)),
          tdyOrTmrw: index == 0 ? 1 : (index == 1 ? 2 : 0),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
