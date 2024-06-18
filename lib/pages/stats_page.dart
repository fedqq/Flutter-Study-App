import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:studyappcs/state_managers/exporter.dart';
import 'package:studyappcs/state_managers/statistics.dart';
import 'package:studyappcs/state_managers/tests_manager.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/utils/expandable_fab.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/utils/snackbar.dart';
import 'package:studyappcs/widgets/studied_chart.dart';

class StatsPage extends StatefulWidget {
  final void Function() saveCallback;
  final void Function() loadCallback;
  final List<Subject> subjects;
  const StatsPage({super.key, required this.saveCallback, required this.loadCallback, required this.subjects});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with SingleTickerProviderStateMixin {
  bool showingNameInput = false;
  late AnimationController controller;
  late Animation<double> animation;

  ExFabController exFabController = ExFabController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this, value: 0, duration: Durations.long3);

    animation = CurvedAnimation(
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOutQuad,
      parent: controller,
    );
    super.initState();
  }

  void editDailyGoal() async {
    String result = await singleInputDialog(
      context,
      'Choose Daily Goal',
      Input(name: 'Goal', numerical: true, validate: (str) => (int.tryParse(str) ?? 0) > 0),
    );
    if (result == '') return;
    setState(() => StudyStatistics.dailyGoal = int.parse(result));
    exFabController.close();
  }

  void editUserName() async {
    String name = await singleInputDialog(
      context,
      'Change Username',
      Input(
        name: 'Username',
        value: StudyStatistics.userName,
      ),
    );
    if (name == '') return;
    setState(() {
      StudyStatistics.userName = name;
    });
    exFabController.close();
  }

  Widget buildButton(String text, void Function() callback) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: FilledButton.tonal(
          onPressed: callback,
          child: Text(text),
        ),
      );

  Widget buildText(String s) => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          s,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );

  Future<File> makeBackup({backup = false}) async {
    widget.saveCallback();
    var path = await getDatabasesPath();
    var resPath = (await getApplicationDocumentsDirectory()).path;
    ZipFileEncoder encoder = ZipFileEncoder();
    encoder.create("$resPath\\studyapp_backup.zip");
    await encoder.addFile(File("$path\\maindata_db.db"));
    await encoder.addFile(File("$path\\stats_db.db"));
    await encoder.addFile(File("$path\\tests.db"));
    await encoder.close();
    return File("$resPath\\studyapp_backup${!backup ? DateTime.now().millisecondsSinceEpoch : ""}.zip");
  }

  void chooseAccentColor() async {
    Color col = await showColorPicker(context, StudyStatistics.color) ?? Colors.black;
    if (col == Colors.black) return;
    StudyStatistics.color = col;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(
          Durations.extralong1,
          () async {
            if (StudyStatistics.userName == '') {
              if (showingNameInput) return;

              showingNameInput = true;
              Future<String?> res =
                  singleInputDialog(context, 'Set User Name', Input(name: 'Name'), cancellable: false);
              String name = await res ?? '';
              setState(() => StudyStatistics.userName = name);
              showingNameInput = false;
            }
          },
        );
      },
    );

    double getRecentAverage() {
      DateTime fromString(String s) {
        var [day, month, year] = s.split('/');

        return DateTime(int.parse(year), int.parse(month), int.parse(day));
      }

      List<Test> pastTests = TestsManager.pastTests;
      pastTests.sort((Test a, Test b) => fromString(a.date).compareTo(fromString(b.date)));
      int sum = 0;
      pastTests.sublist(0, min(10, pastTests.length)).forEach((Test element) => sum += element.percentage);
      return sum / 10;
    }

    double getAllAverage() {
      List<Test> tests = TestsManager.pastTests;
      int total = 0;
      int length = tests.length;
      for (var element in tests) {
        total += element.totalAmount;
      }
      return total / length;
    }

    TextTheme theme = Theme.of(context).textTheme;

    controller.forward();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, __) {
        double elevation = 2 * animation.value;

        return Scaffold(
          appBar: AppBar(
            actions: [IconButton(onPressed: showThemeOptions, icon: const Icon(Icons.settings_rounded))],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              FittedBox(
                fit: BoxFit.fitHeight,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Hello ${StudyStatistics.userName}', style: theme.displaySmall),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Text(
                        'Today you have studied ${StudyStatistics.getTodayStudied()} cards out of ${StudyStatistics.dailyGoal}',
                        style: theme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.all(8),
                elevation: elevation,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(52, 20, 52, 50),
                    child: StudiedChart(animValue: animation.value),
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(8),
                elevation: elevation,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      buildText('You are currently on a ${StudyStatistics.calculateStreak()} day streak'),
                      buildText('Your highest streak was ${StudyStatistics.maxStreak} days'),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 80,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  elevation: elevation,
                  child: ListView(
                    padding: const EdgeInsets.all(12.0),
                    scrollDirection: Axis.horizontal,
                    children: [
                      buildButton('Export Data', exportData),
                      buildButton('Import Data', importData),
                      buildButton(
                        'Data to PDF',
                        () {
                          widget.saveCallback();
                          Exporter.printEverything(widget.subjects);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (TestsManager.pastTests.isNotEmpty)
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: elevation,
                  child: Column(
                    children: [
                      buildText(
                          'Average 10 test percentages: ${getRecentAverage()}% (${getRecentAverage() - getAllAverage() >= 0 ? '+' : ''}${(getRecentAverage() - getAllAverage())}%)'),
                      buildText('Average total test percentages: ${getAllAverage()}%'),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void showThemeOptions() {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: editUserName,
                label: const Row(
                  children: [
                    Text("Edit Username"),
                  ],
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                iconAlignment: IconAlignment.end,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: editDailyGoal,
                label: const Row(
                  children: [
                    Text("Edit Daily Goal"),
                  ],
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                iconAlignment: IconAlignment.end,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton(onPressed: useDeviceAccentColor, child: const Text("Use Device Accent Color")),
                  )),
                  InkWell(
                    onTap: chooseAccentColor,
                    child: Container(
                        decoration: BoxDecoration(color: StudyStatistics.color, shape: BoxShape.circle),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.edit_rounded),
                        )),
                  ),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Light Mode"),
                    Switch(value: StudyStatistics.lightness, onChanged: (b) => StudyStatistics.lightness = b)
                  ],
                )),
          ],
        );
      },
    );
  }

  void useDeviceAccentColor() async {
    StudyStatistics.color = await DynamicColorPlugin.getAccentColor() ?? Colors.blue;
  }

  void exportData() async => Share.shareXFiles([XFile((await makeBackup()).path)]);

  void importData() async {
    String dbPath = await getDatabasesPath();

    void loadFromDirectory(String pathToDir) async {
      File("$dbPath\\maindata_db.db").writeAsBytesSync(File("$pathToDir\\maindata_db.db").readAsBytesSync());
      File("$dbPath\\stats_db.db").writeAsBytesSync(File("$pathToDir\\stats_db.db").readAsBytesSync());
      File("$dbPath\\tests.db").writeAsBytesSync(File("$pathToDir\\tests.db").readAsBytesSync());
    }

    Future clearData() async {
      File("$dbPath\\maindata_db.db").writeAsStringSync('');
      File("$dbPath\\stats_db.db").writeAsStringSync('');
      File("$dbPath\\tests.db").writeAsStringSync('');
    }

    await makeBackup(backup: true);
    try {
      String path =
          (await FilePicker.platform.pickFiles(allowMultiple: false, allowedExtensions: ['.zip']))?.paths[0] ?? "";
      if (path == "") {
        return;
      }

      String unzippedPath = "${(await getApplicationDocumentsDirectory()).path}\\unzip\\";
      extractFileToDisk(path, unzippedPath);
      clearData();
      loadFromDirectory(unzippedPath);
      StudyStatistics.load();
      widget.loadCallback();
      TestsManager.load();
    } catch (e) {
      // ignore: use_build_context_synchronously
      simpleSnackBar(context, "Error importing data. ");
      String unzippedPath = "${(await getApplicationDocumentsDirectory()).path}\\backupunzip\\";
      extractFileToDisk("${(await getApplicationDocumentsDirectory()).path}\\studyapp_backup.zip", unzippedPath);
      clearData();
      loadFromDirectory(unzippedPath);
      StudyStatistics.load();
      widget.loadCallback();
      TestsManager.load();
      dev.log(e.toString());
    }
  }
}
