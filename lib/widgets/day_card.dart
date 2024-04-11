import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:intl/intl.dart';

class DayCard extends StatefulWidget {
  final DateTime date;
  final int tdyOrTmrw;
  const DayCard({super.key, required this.date, required this.tdyOrTmrw});

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  @override
  Widget build(BuildContext context) {
    return GradientOutline(
      gradient: Theming.grayGradient,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat.yMMMMd('en_US').format(widget.date),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
