import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:studyapp/state_managers/statistics.dart';
import 'package:studyapp/states/subject.dart';
import 'package:studyapp/states/topic.dart';

class Exporter {
  static pw.Page subjectToPdf(Subject subject, int scoresToShow) {
    return pw.Page(
      build: (pw.Context context) => pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                subject.name,
                style: pw.Theme.of(context).header0,
              ),
              pw.Container(color: PdfColor.fromInt(subject.color.value), height: 30, width: 30),
            ],
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
            child: pw.Container(width: double.infinity, height: 5, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text(
              '${subject.topics.length} topic(s) and ${countCards(subject)} card(s)',
              style: pw.Theme.of(context).bulletStyle.copyWith(fontSize: 10),
            ),
            pw.Text(
              'Tested ${subject.testScores.length} times',
              style: pw.Theme.of(context).bulletStyle.copyWith(fontSize: 10),
            ),
          ]),
          pw.SizedBox(height: 10),
          ...getScoresList(context, subject, scoresToShow),
          pw.SizedBox(height: 10),
          pw.ListView.builder(
            itemBuilder: (context, index) => topicWidget(context, subject.topics[index]),
            itemCount: subject.topics.length,
          ),
        ],
      ),
    );
  }

  static void printEverything(List<Subject> subjects) async {
    final pdf = pw.Document(author: StudyStatistics.userName);
    for (Subject subject in subjects) {
      pdf.addPage(subjectToPdf(subject, 10));
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${'all-subjects'}-${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    Share.shareXFiles([XFile(file.path)]);
  }

  static void printSubject(Subject subject, int scoresToShow) async {
    final pdf = pw.Document()..addPage(subjectToPdf(subject, scoresToShow));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${subject.name}-${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    Share.shareXFiles([XFile(file.path)]);
  }

  static List<pw.Widget> getScoresList(pw.Context context, Subject subject, int scoresToShow) => [
        pw.Row(children: [pw.Text('Test Scores: ')]),
        pw.SizedBox(height: 4),
        pw.Row(
          children: List.generate(
            min(subject.testScores.length, scoresToShow),
            (index) => pw.Text(
              '${subject.testScores[index]}%, ',
              style: pw.Theme.of(context).bulletStyle.copyWith(fontSize: 10),
            ),
          ),
        ),
      ];

  static int countCards(Subject subject) {
    int i = 0;
    for (Topic t in subject.topics) {
      i += t.cards.length;
    }

    return i;
  }

  static pw.Widget topicWidget(pw.Context context, Topic topic) {
    return pw.Align(
      alignment: pw.Alignment.topLeft,
      child: pw.Column(
        children: [
          pw.Text(topic.name, style: pw.Theme.of(context).header1),
          pw.SizedBox(height: 10),
          pw.ListView.builder(
            itemBuilder: (context, index) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
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
  }
}
