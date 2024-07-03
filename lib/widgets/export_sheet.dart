import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studyappcs/data_managers/exporter.dart' as exporter;
import 'package:studyappcs/states/subject.dart';

Future<void> export(BuildContext context, Subject subject) async {
  final String res = subject.toString();
  final String dir = (await getTemporaryDirectory()).path;
  final File temp = File('$dir/${subject.name}.txt');

  await temp.writeAsString(res);
  await Share.shareXFiles(<XFile>[XFile('$dir/${subject.name}.txt')]);
}

void showPrintMenu(BuildContext context, Subject subject) {
  const BasicSlider slider = BasicSlider(scoresShow: 0);

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Export ${subject.name}', style: Theme.of(context).textTheme.headlineMedium),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('PDF Options: ', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const Text('Scores to show: '),
                  slider,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: FilledButton(
              onPressed: () {
                exporter.printSubject(subject, slider.scoresShow.toInt());
                Navigator.of(context).pop();
              },
              child: const Text('Save as PDF'),
            ),
          ),
        ],
      ),
    ),
    showDragHandle: true,
  );
}

void showPrintOrExport(BuildContext context, Subject subject) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text('Print or export ${subject.name}'),
      actions: <Widget>[
        FilledButton.tonal(onPressed: Navigator.of(context).pop, child: const Text('Cancel')),
        FilledButton(onPressed: () => export(context, subject), child: const Text('As TXT')),
        FilledButton(onPressed: () => showPrintMenu(context, subject), child: const Text('As PDF')),
      ],
    ),
  );
}

class BasicSlider extends StatefulWidget {
  const BasicSlider({super.key, required this.scoresShow});
  final double scoresShow;

  @override
  State<BasicSlider> createState() => _BasicSliderState();
}

class _BasicSliderState extends State<BasicSlider> {
  double scoresShow = 0;
  @override
  Widget build(BuildContext context) => SliderTheme(
        data: SliderThemeData(tickMarkShape: SliderTickMarkShape.noTickMark),
        child: Slider(
          label: 'Show $scoresShow scores',
          divisions: 30,
          value: scoresShow,
          onChanged: (double i) => setState(() {
            scoresShow += i - scoresShow;
          }),
          max: 30,
          allowedInteraction: SliderInteraction.tapAndSlide,
        ),
      );
}
