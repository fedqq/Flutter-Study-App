import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studyappcs/state_managers/exporter.dart';
import 'package:studyappcs/states/subject.dart';

void export(BuildContext context, Subject subject) async {
  String res = subject.toString();
  String dir = (await getTemporaryDirectory()).path;
  File temp = File('$dir/${subject.name}.txt');

  await temp.writeAsString(res);
  await Share.shareXFiles([XFile('$dir/${subject.name}.txt')]);
}

void showPrintMenu(BuildContext context, Subject subject) {
  TextTheme theme = Theme.of(context).textTheme;

  BasicSlider slider = const BasicSlider(scoresShow: 0);

  showModalBottomSheet(
    context: context,
    builder: (context) => Align(
      alignment: Alignment.topCenter,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Export ${subject.name}', style: theme.headlineMedium),
        ),
        Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 3.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('PDF Options: ', style: theme.titleLarge),
                ),
                const Text('Scores to show: '),
                slider,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FilledButton(
            onPressed: () {
              Exporter.printSubject(subject, slider.scoresShow.toInt());
              Navigator.of(context).pop();
            },
            child: const Text('Save as PDF'),
          ),
        ),
      ]),
    ),
    showDragHandle: true,
  );
}

void showPrintOrExport(BuildContext context, Subject subject) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(title: Text('Print or export ${subject.name}'), actions: [
      FilledButton.tonal(onPressed: Navigator.of(context).pop, child: const Text('Cancel')),
      FilledButton(onPressed: () => export(context, subject), child: const Text('As TXT')),
      FilledButton(onPressed: () => showPrintMenu(context, subject), child: const Text('As PDF')),
    ]),
  );
}

class BasicSlider extends StatefulWidget {
  final double scoresShow;
  const BasicSlider({super.key, required this.scoresShow});

  @override
  State<BasicSlider> createState() => _BasicSliderState();
}

class _BasicSliderState extends State<BasicSlider> {
  double scoresShow = 0;
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(tickMarkShape: SliderTickMarkShape.noTickMark),
      child: Slider(
        label: 'Show $scoresShow scores',
        divisions: 30,
        value: scoresShow,
        onChanged: (i) => setState(() {
          scoresShow += (i - scoresShow);
        }),
        max: 30,
        allowedInteraction: SliderInteraction.tapAndSlide,
      ),
    );
  }
}
