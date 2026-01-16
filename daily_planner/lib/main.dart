import 'package:flutter/material.dart';
import 'daily_timeline.dart';
import 'todo_manager.dart';

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
    // Sample todos for the timeline
    final now = DateTime.now();
    _todoManager.addTodo(title: 'Réveil', deadline: DateTime(now.year, now.month, now.day, 7, 0));
    _todoManager.addTodo(title: 'Aller au travail', deadline: DateTime(now.year, now.month, now.day, 8, 30));
    _todoManager.addTodo(title: 'Stand-up', description: 'Réunion quotidienne', deadline: DateTime(now.year, now.month, now.day, 9, 0));
    _todoManager.addTodo(title: 'Déjeuner', deadline: DateTime(now.year, now.month, now.day, 12, 30));
    _todoManager.addTodo(title: 'Focus projet', deadline: DateTime(now.year, now.month, now.day, 15, 0));
    _todoManager.addTodo(title: 'Sport', deadline: DateTime(now.year, now.month, now.day, 18, 0));
    _todoManager.addTodo(title: 'Dîner', deadline: DateTime(now.year, now.month, now.day, 20, 0));
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
          _buildTodoList(),
          // Daily timeline (index 1)
          Center(child: DailyTimeline(manager: _todoManager)),
          // Profile (index 2)
          Center(child: Text('Profile', style: Theme.of(context).textTheme.headlineMedium)),
        ],
      ),
    ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddTodoDialog,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_outlined),
                  activeIcon: Icon(Icons.list),
                  label: 'To Do',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Daily',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.grey.shade600,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
              iconSize: 24.0,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    final todos = _todoManager.getActiveTodos();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('To Do', style: Theme.of(context).textTheme.headlineMedium),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: todos.isEmpty
                ? Center(child: Text('Aucun todo actif', style: Theme.of(context).textTheme.bodyLarge))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final t = todos[index];
                      final time = '${t.deadline.hour.toString().padLeft(2, '0')}:${t.deadline.minute.toString().padLeft(2, '0')} ${t.deadline.day}/${t.deadline.month}';
                      return Dismissible(
                        key: ValueKey(t.id),
                        background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20.0), child: const Icon(Icons.delete, color: Colors.white)),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          setState(() {
                            _todoManager.removeTodoById(t.id);
                          });
                        },
                        child: Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: t.isCompleted,
                              onChanged: (v) {
                                if (v == true) {
                                  setState(() {
                                    _todoManager.markCompleted(t.id);
                                  });
                                }
                              },
                            ),
                            title: Text(t.title),
                            subtitle: Text(time + (t.description != null ? ' · ${t.description}' : '')),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                setState(() {
                                  _todoManager.removeTodoById(t.id);
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTodoDialog() async {
    String title = '';
    String? description;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Titre'),
                onChanged: (v) => title = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description (optionnelle)'),
                onChanged: (v) => description = v,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final t = title.trim();
                if (t.isNotEmpty) {
                  setState(() {
                    _todoManager.addTodo(title: t, description: description, deadline: DateTime.now().add(const Duration(hours: 1)));
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
