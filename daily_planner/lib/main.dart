import 'package:flutter/material.dart';
import 'timeline/daily_timeline.dart';
import 'package:daily_planner/todolist/todo_manager.dart';
import 'todolist/todo_list_page.dart';
import 'todolist/edit_todo_page.dart';
import 'widgets/custom_bottom_navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Planner',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      home: const MyHomePage(title: 'Daily Planner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _selectedIndex = 1;
  final TodoManager _todoManager = TodoManager();

  @override
  void initState() {
    super.initState();
    // Initialize DB and add sample todos if DB empty
    _todoManager.init().then((_) async {
      final now = DateTime.now();
      if (_todoManager.getActiveTodos().isEmpty) {
        await _todoManager.addTodo(title: 'Réveil', deadline: DateTime(now.year, now.month, now.day, 7, 0));
        await _todoManager.addTodo(title: 'Aller au travail', deadline: DateTime(now.year, now.month, now.day, 8, 30));
        await _todoManager.addTodo(title: 'Stand-up', description: 'Réunion quotidienne', deadline: DateTime(now.year, now.month, now.day, 9, 0));
        await _todoManager.addTodo(title: 'Déjeuner', deadline: DateTime(now.year, now.month, now.day, 12, 30));
        await _todoManager.addTodo(title: 'Focus projet', deadline: DateTime(now.year, now.month, now.day, 15, 0));
        await _todoManager.addTodo(title: 'Sport', deadline: DateTime(now.year, now.month, now.day, 18, 0));
        await _todoManager.addTodo(title: 'Dîner', deadline: DateTime(now.year, now.month, now.day, 20, 0));
        setState(() {});
      }
    });
  }

  static const List<String> _pageTitles = <String>[
    'To Do List',
    'Daily Planner',
    'Profile',
  ];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
          // To Do List (index 0)
          TodoListPage(manager: _todoManager),
          // Daily timeline (index 1)
          Center(child: DailyTimeline(manager: _todoManager)),
          // Profile (index 2)
          Center(child: Text('Profile', style: Theme.of(context).textTheme.headlineMedium)),
        ],
      ),
    ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<Map<String, dynamic>?>(
                  MaterialPageRoute(builder: (_) => const EditTodoPage()),
                );
                if (result != null) {
                  await _todoManager.addTodo(
                    title: result['title'] as String,
                    description: result['description'] as String?,
                    deadline: result['deadline'] as DateTime,
                  );
                  setState(() {});
                }
              },
              tooltip: 'Add Todo',
              child: const Icon(Icons.add),
            )
          : _selectedIndex == 1
              ? FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                )
              : null,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  
}
