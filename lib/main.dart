import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_details.dart';
import 'new_workout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<dynamic>> _fetchUsers() async {
    List<dynamic> users = [];
    try {
      final usuarioData = {
        'action': 'getusers',
      };

      final response = await http.post(
        Uri.parse(
            'https://container-134012752825.europe-southwest1.run.app/usuarios'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(usuarioData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        users = jsonDecode(response.body);
      } else {
        throw Exception('Error fetching users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
    return users;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<List<dynamic>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return MyHomePage(title: 'ProFit Bands', users: snapshot.data ?? []);
          }
        },
      ),
      routes: {
        '/userDetails': (context) => const UserDetailsPage(),
        '/newUser': (context) => NewUserPage(onUserAdded: () {
              final myHomePageState =
                  context.findAncestorStateOfType<_MyHomePageState>();
              myHomePageState?.refreshUsers();
            }),
        '/modifyUser': (context) => const ModifyUserPage(),
        '/newWorkout': (context) => const NewWorkoutView(), 
        '/contarRepeticiones': (context) => const Placeholder(), // Added route
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<dynamic> users;
  final String title;
  final VoidCallback? onUserAdded; 

  const MyHomePage(
      {super.key, required this.title, required this.users, this.onUserAdded});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> users = []; 
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    users = widget.users; 
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      final usuarioData = {
        'action': 'getusers',
      };

      final response = await http.post(
        Uri.parse(
            'https://container-134012752825.europe-southwest1.run.app/usuarios'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(usuarioData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          users = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error fetching users: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching users: $e';
        isLoading = false;
      });
    }
  }

  void refreshUsers() {
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLoading)
              const CircularProgressIndicator()
            else if (error.isNotEmpty)
              Text(error)
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: users.map((user) {
                            return ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/userDetails',
                                    arguments: user);
                              },
                              icon: const Icon(Icons.person),
                              label: SizedBox(
                                width: 100,
                                child: Center(
                                  child: Text(user['nick']),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _fetchUsers,
              tooltip: 'Fetch Users',
              child: const Icon(Icons.download),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/newUser');
              },
              tooltip: 'Add New User',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
