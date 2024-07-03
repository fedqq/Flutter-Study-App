import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:studyappcs/data_managers/user_data.dart' as user_data;
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/topic.dart';

pw.Page subjectToPdf(Subject subject, int scoresToShow) => pw.Page(
      build: (pw.Context context) => pw.Column(
        children: <pw.Widget>[
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: <pw.Widget>[
              pw.Text(
                subject.name,
                style: pw.Theme.of(context).header0,
              ),
              pw.Container(color: PdfColor.fromInt(subject.color.value), height: 30, width: 30),
            ],
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Container(width: double.infinity, height: 5, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: <pw.Widget>[
              pw.Text(
                '${subject.topics.length} topic(s) and ${countCards(subject)} card(s)',
                style: pw.Theme.of(context).bulletStyle.copyWith(fontSize: 10),
              ),
              pw.Text(
                'Tested ${subject.testScores.length} times',
                style: pw.Theme.of(context).bulletStyle.copyWith(fontSize: 10),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          ...getScoresList(context, subject, scoresToShow),
          pw.SizedBox(height: 10),
          pw.ListView.builder(
            itemBuilder: (pw.Context context, int index) => topicWidget(context, subject.topics[index]),
            itemCount: subject.topics.length,
          ),
        ],
      ),
    );

Future<void> printEverything(List<Subject> subjects) async {
  final pw.Document pdf = pw.Document(author: user_data.userName);
  for (final Subject subject in subjects) {
    pdf.addPage(subjectToPdf(subject, 10));
  }
  final Directory dir = await getTemporaryDirectory();
  final File file = File('${dir.path}/${'all-subjects'}-${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(await pdf.save());
  await Share.shareXFiles(<XFile>[XFile(file.path)]);
}

Future<void> printSubject(Subject subject, int scoresToShow) async {
  final pw.Document pdf = pw.Document()..addPage(subjectToPdf(subject, scoresToShow));
  final Directory dir = await getTemporaryDirectory();
  final File file = File('${dir.path}/${subject.name}-${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(await pdf.save());
  await Share.shareXFiles(<XFile>[XFile(file.path)]);
}

List<pw.Widget> getScoresList(pw.Context context, Subject subject, int scoresToShow) => <pw.Widget>[
      pw.Row(children: <pw.Widget>[pw.Text('Test Scores: ')]),
      pw.SizedBox(height: 4),
      pw.Row(
        children: List<pw.Text>.generate(
          min(subject.testScores.length, scoresToShow),
          (int index) => pw.Text(
            '${subject.testScores[index]}%, ',
            style: pw.Theme.of(context).bulletStyle.copyWith(fontSize: 10),
          ),
        ),
      ),
    ];

int countCards(Subject subject) {
  int i = 0;
  for (final Topic t in subject.topics) {
    i += t.cards.length;
  }

  return i;
}

pw.Widget topicWidget(pw.Context context, Topic topic) => pw.Align(
    alignment: pw.Alignment.topLeft,
    child: pw.Column(
      children: <pw.Widget>[
        pw.Text(topic.name, style: pw.Theme.of(context).header1),
        pw.SizedBox(height: 10),
        pw.ListView.builder(
          itemBuilder: (pw.Context context, int index) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: <pw.Widget>[
              pw.Text(topic.cards[index].name),
              pw.Text(topic.cards[index].meaning),
            ],
          ),
          itemCount: topic.cards.length,
        ),
        pw.SizedBox(height: 10),
      ],
    ),
  );
