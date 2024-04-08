import 'dart:ui';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/data_manager.dart';
import 'package:flutter_application_1/subject_page.dart';
import 'package:flutter_application_1/subject.dart';

import 'package:flutter_application_1/task.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

// ignore: unused_import
import 'dart:developer' as developer;

// ignore: constant_identifier_names
const bool CLEAR = false;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study App',
      theme: ThemeData(
          colorScheme: const ColorScheme.dark(),
          useMaterial3: true,
          indicatorColor: const Color.fromARGB(255, 87, 61, 255),
          fontFamily: 'Inter'),
      home: const MyHomePage(title: 'Study Help App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<Subject> _subjects = [];
  List<Task> _tasks = [];
  final List<Task> _completedTasks = [];
  int _selectedDestination = 0;
  bool initialLoaded = false;

  late TextEditingController newSubjectNameController;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SaveDataManager.saveData(_subjects, _tasks);
    super.dispose();
  }

  @override
  void initState() {
    loadData();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void loadData() async {
    var subjectData = await SaveDataManager.loadSubjects();
    var taskData = await SaveDataManager.loadTasks();
    setState(() {
      _subjects = subjectData;
      int i = 0;
      for (Subject subject in _subjects) {
        subject.topics = subjectData[i].topics;
        i++;
      }
      _tasks = taskData;
    });
    initialLoaded = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    SaveDataManager.saveData(_subjects, _tasks);
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();

    void selectDestination(int index) {
      setState(() {
        _selectedDestination = index;
        pageController.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      });
    }

    void pageChanged(int index) {
      setState(() {
        _selectedDestination = index;
      });
    }

    void study(Subject subject) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectPage(subject: subject)));
    }

    List<String> getSubjectNames() {
      return List.generate(_subjects.length, (index) => _subjects[index].name);
    }

    void editSubject(int index) async {
      String newName = await prompt(
            title: Text('Choose new name for ${_subjects[index].name}'),
            context,
          ) ??
          '';
      if (getSubjectNames().contains(newName)) {
        return;
      } else {
        setState(() => _subjects[index].name = newName);
      }
    }

    void deleteSubject(Subject subject) async {
      if (_subjects.length == 1) {
        return;
      }
      if (await confirm(context, title: Text('Delete ${subject.name}'))) {
        setState(() => _subjects.remove(subject));
      }
    }

    Future<Color?> showColorPicker(Color color) async {
      Color tempColor = color;
      return showDialog<Color>(
          context: context,
          builder: (_) => AlertDialog(
                  contentPadding: const EdgeInsets.all(8.0),
                  title: const Text('Choose a color'),
                  content: MaterialColorPicker(
                    onColorChange: (value) => tempColor = value,
                    selectedColor: color,
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, tempColor), child: const Text('Confirm'))
                  ]));
    }

    void editColor(int index) async {
      Color? newColor = await showColorPicker(_subjects[index].color);
      if (newColor == null) {
        return;
      } else {
        setState(() => _subjects[index].color = newColor);
      }
    }

    void newSubject() async {
      String name = await prompt(
            context,
            title: const Text('New Subject Name'),
          ) ??
          '';
      if (context.mounted) {
        if (getSubjectNames().contains(name)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Subject called $name already exists'),
          ));
          return;
        }

        if (name == '') {
          return;
        }
      }

      Color? newColor = await showColorPicker(Colors.blue);
      if (newColor == null) {
        return;
      }

      final subject = Subject(name, icon: Icons.add_rounded, colour: newColor);
      setState(() {
        _subjects.add(subject);
      });
    }

    List<Widget> childs = [
      const Scaffold(
        body: SizedBox(),
        backgroundColor: Colors.transparent,
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Center(
                child: Text(_subjects.length == 1 ? 'Study 1 subject' : 'Study ${_subjects.length} subjects',
                    style: const TextStyle(fontWeight: FontWeight.bold)))),
        floatingActionButton: Container(
          decoration: Theming.gradientDeco,
          child: FloatingActionButton(
            onPressed: newSubject,
            tooltip: 'New Subject',
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            hoverElevation: 0,
            child: const Icon(Icons.add_rounded),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _subjects.length,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: _subjects[index].color.withAlpha(60),
                  blurRadius: 10.0,
                  spreadRadius: -10.0,
                  offset: const Offset(
                    0.0,
                    3.0,
                  ),
                ),
              ],
            ),
            child: Theming.grayOutline(
                InkWell(
                  borderRadius: BorderRadius.zero,
                  onTap: () => study(_subjects[index]),
                  child: Card(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12, tileMode: TileMode.decal),
                            child: Hero(
                              tag: 'colorbox:${_subjects[index].name}',
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Theming.radius - Theming.padding - 8),
                                    gradient: Theming.gradientToDarker(_subjects[index].color)),
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(),
                                Row(
                                  children: [
                                    Center(
                                      child: Text(_subjects[index].name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.color_lens_rounded),
                                        onPressed: () => editColor(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded),
                                        onPressed: () => editSubject(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_rounded),
                                        onPressed: () => deleteSubject(_subjects[index]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                outerPadding: 8.0),
          ),
        ),
      ),
      Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: Container(
            decoration: Theming.gradientDeco,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              hoverElevation: 0,
              onPressed: () async {
                String name = await prompt(context, title: const Text('New Task Name')) ?? "";
                DateTime invalidPlaceholder = DateTime.fromMillisecondsSinceEpoch(10000);
                if (name != "" && context.mounted) {
                  DateTime date = await showDatePicker(
                          initialDate: DateTime.now(),
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 1000))) ??
                      DateTime.fromMillisecondsSinceEpoch(10000);
                  if (date == invalidPlaceholder) {
                    return;
                  }
                  setState(() {
                    _tasks.add(Task(TaskType.assignment, name, date, false));
                  });
                }
              },
              tooltip: 'New Task',
              child: const Icon(Icons.add_rounded),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _tasks.length,
            itemBuilder: (context, index) => CheckboxListTile(
                title: Text(_tasks[index].task),
                value: _tasks[index].completed,
                onChanged: (changed) {
                  setState(() {
                    Task task = _tasks[index];
                    Future.delayed(Durations.long1, () {
                      setState(() => _tasks.remove(task));
                    });
                    _tasks[index].completed = true;
                    _completedTasks.add(task);
                  });
                }),
          )),
    ];
    if (CLEAR) {
      SaveDataManager.clearAll();
    }

    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    HSLColor hslBg = HSLColor.fromColor(bgColor);

    return Stack(
      children: [
        Positioned.fill(
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [bgColor, hslBg.withLightness(hslBg.lightness - 0.03).toColor()])))),
        Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(),
            bottomNavigationBar: Theming.gradientOutline(NavigationBar(
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              selectedIndex: _selectedDestination,
              indicatorColor: const Color.fromARGB(255, 66, 37, 255),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.query_stats_outlined), label: "Stats"),
                NavigationDestination(icon: Icon(Icons.school_outlined), label: "Study"),
                NavigationDestination(icon: Icon(Icons.check_outlined), label: "Tasks")
              ],
              backgroundColor: Colors.transparent,
              onDestinationSelected: selectDestination,
            )),
            body: PageView(
              controller: pageController,
              onPageChanged: pageChanged,
              padEnds: false,
              children: childs,
            ))
      ],
    );
  }
}
