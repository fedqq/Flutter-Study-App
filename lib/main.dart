import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_manager.dart';
import 'package:flutter_application_1/study_page.dart';
import 'package:flutter_application_1/subject.dart';
import 'dart:developer' as developer;

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
          indicatorColor: const Color.fromARGB(255, 87, 61, 255)),
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
  List<Subject> _subjects = [Subject('Math'), Subject('Physics', colour: const Color.fromARGB(255, 193, 193, 0))];
  int _selectedDestination = 0;

  late TextEditingController newSubjectNameController;

  @override
  void dispose() {
    developer.log('dispose');
    newSubjectNameController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    DataManager.saveData(_subjects);
    super.dispose();
  }

  @override
  void initState() {
    developer.log('initState');
    newSubjectNameController = TextEditingController();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadData();
  }

  void saveData() {
    developer.log('saving');
    DataManager.saveData(_subjects);
    developer.log('Saved');
  }

  void loadData() async {
    var data = await DataManager.loadData();
    setState(() {
      _subjects = data.subjects;
      int i = 0;
      for (Subject subject in _subjects) {
        subject.topics = data.subjects[i].topics;
        i++;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    developer.log('anything');
    if (state == AppLifecycleState.paused) {
      DataManager.saveData(_subjects);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();
    const double radius = 20;
    const double padding = 3;

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

    BoxDecoration gradDeco = BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color.fromARGB(255, 135, 0, 193), Color.fromARGB(255, 34, 0, 253)]),
        borderRadius: BorderRadius.circular(radius));

    BoxDecoration innerDeco = BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Color.fromARGB(255, 15, 15, 15), Color.fromARGB(255, 19, 19, 19)]),
        borderRadius: BorderRadius.circular(radius - padding));

    BoxDecoration grayDeco = BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color.fromARGB(130, 224, 224, 224), Color.fromARGB(100, 146, 146, 146)]),
        borderRadius: BorderRadius.circular(radius));

    const BoxDecoration transparent = BoxDecoration(color: Colors.transparent);

    Container grayOutline(Widget child) {
      return Container(
          decoration: transparent,
          padding: const EdgeInsets.all(15),
          child: Container(
              decoration: grayDeco,
              padding: const EdgeInsets.all(padding),
              child: Container(decoration: innerDeco, child: child)));
    }

    Container gradientOutline(Widget child) {
      return Container(
          decoration: transparent,
          padding: const EdgeInsets.all(15),
          child: Container(
              decoration: gradDeco,
              padding: const EdgeInsets.all(padding),
              child: Container(decoration: innerDeco, child: child)));
    }

    LinearGradient makeDarker(Color color) {
      HSLColor hsl = HSLColor.fromColor(color);
      hsl = hsl.withLightness(hsl.lightness - 0.2);
      return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, hsl.toColor()]);
    }

    void study(Subject subject) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => StudyPage(subject: subject)));
    }

    List<Widget> childs = [
      const Card(
        shadowColor: Colors.transparent,
        margin: EdgeInsets.all(8.0),
        child: SizedBox.expand(
          child: Center(
            child: Text(
              'Stats Page',
            ),
          ),
        ),
      ),
      Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final subject = await newSubjectDialog();
            if (subject == null || subject.name == '') {
              return;
            }
            setState(() {
              _subjects.add(subject);
            });
            DataManager.addSubject(subject.name);
          },
          tooltip: 'New Subject',
          backgroundColor: Theme.of(context).indicatorColor,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
            addAutomaticKeepAlives: true,
            padding: const EdgeInsets.all(10),
            itemCount: _subjects.length,
            itemBuilder: (context, index) => grayOutline(Container(
                margin: const EdgeInsets.all(10),
                child: GestureDetector(
                    onTap: () => study(_subjects[index]),
                    child: Card(
                        semanticContainer: true,
                        shape:
                            const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius - 10))),
                        child: Center(
                            child: Column(
                          children: [
                            Hero(
                                tag: 'colorbox:${_subjects[index].name}',
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(radius - 10)),
                                      gradient: makeDarker(_subjects[index].color)),
                                )),
                            Container(
                              margin: const EdgeInsets.all(20),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _subjects[index].name,
                                      style: Theme.of(context).textTheme.titleLarge,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                Hero(
                                    tag: 'icon:${_subjects[index].name}',
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(_subjects[index].icon, size: 100)))
                              ]),
                            )
                          ],
                        ))))))),
      ),
      const Scaffold(
        body: SizedBox.expand(
          child: Center(
            child: Text(
              'Tasks Page',
            ),
          ),
        ),
      ),
    ];
    return Scaffold(
        bottomNavigationBar: gradientOutline(NavigationBar(
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
        body: PageView(controller: pageController, onPageChanged: pageChanged, children: childs));
  }

  void submitNewSubject(context) {
    Navigator.of(context).pop(Subject(newSubjectNameController.text));
    newSubjectNameController.clear();
  }

  Future<Subject?> newSubjectDialog() => showDialog<Subject?>(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('New Subject Name'),
          content: TextField(
            controller: newSubjectNameController,
            autofocus: true,
            onSubmitted: (String? _) => submitNewSubject(context),
          ),
          actions: [TextButton(onPressed: () => submitNewSubject(context), child: const Text('Confirm'))]));
}
