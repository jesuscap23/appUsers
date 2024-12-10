import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:intl/intl.dart';

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
              //This callback refreshes the user list after adding a new user
              final myHomePageState =
                  context.findAncestorStateOfType<_MyHomePageState>();
              myHomePageState?._fetchUsers();
            }),
        '/modifyUser': (context) => const ModifyUserPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<dynamic> users;
  final String title;
  final VoidCallback? onUserAdded; // Callback for when a user is added

  const MyHomePage(
      {super.key, required this.title, required this.users, this.onUserAdded});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> users = []; // Initialize as an empty list
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    users = widget.users; // Initialize users in initState
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

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  Future<void> _deleteUser(String userId) async {
    try {
      final usuarioData = {
        'action': 'deleteuser',
        'user_id': userId,
      };

      final response = await http.delete(
        Uri.parse(
            'https://container-134012752825.europe-southwest1.run.app/usuarios'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(usuarioData),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado correctamente')),
        );
        Navigator.pop(context); // Go back to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchUser(String userId) async {
    try {
      final usuarioData = {
        'action': 'getuser',
        'user_id': userId,
      };

      final response = await http.post(
        Uri.parse(
            'https://container-134012752825.europe-southwest1.run.app/usuarios'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(usuarioData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user: ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user: $e')),
      );
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    final user =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userId = user['id'];
    final imageUrl = user['imageUrl']; // Assuming imageUrl is in the JSON

    return Scaffold(
      appBar: AppBar(title: Text('User Details: ${user['nick']}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // User Image
            CircleAvatar(
              radius: 50,
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null, // Handle cases where imageUrl is null or empty
              child: imageUrl == null || imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),

            // Nickname (prominently displayed)
            Text(
              user['nick'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Full Name (on one line)
            Text(
              '${user['nombre']} ${user['apellido1']} ${user['apellido2']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Other details (using Row for better layout)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email),
                const SizedBox(width: 8),
                Text(user['email']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone),
                const SizedBox(width: 8),
                Text(user['movil']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(user['ano_nacimiento']),
              ],
            ),
            const SizedBox(height: 16),

            // Buttons (using Row for better layout)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _deleteUser(userId),
                  child: const Text('Eliminar Usuario'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/modifyUser', arguments: user);
                  },
                  child: const Text('Modificar Usuario'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NewUserPage extends StatefulWidget {
  final VoidCallback? onUserAdded; // Callback function

  const NewUserPage({super.key, this.onUserAdded});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nickController = TextEditingController();
  final _nombreController = TextEditingController();
  final _primerApellidoController = TextEditingController();
  final _segundoApellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _anoNacimientoController = TextEditingController();
  bool _isSubmitted = false;

  final RegExp _emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final RegExp _phoneRegExp = RegExp(r"^\+?[1-9]\d{1,14}$");

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitted = true;
      });
      final usuarioData = {
        'action': 'createuser',
        'nick': _nickController.text,
        'nombre': _nombreController.text,
        'apellido1': _primerApellidoController.text,
        'apellido2': _segundoApellidoController.text,
        'email': _emailController.text,
        'movil': _telefonoController.text,
        'ano_nacimiento': _anoNacimientoController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado correctamente')),
        );
        widget.onUserAdded?.call(); // Call the callback
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minYear = now.year - 12;
    final maxYear = now.year;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nickController,
                decoration: const InputDecoration(labelText: 'Nick'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nick';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nombre';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _primerApellidoController,
                decoration: const InputDecoration(labelText: 'Primer Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your primer apellido';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _segundoApellidoController,
                decoration:
                    const InputDecoration(labelText: 'Segundo Apellido'),
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!_emailRegExp.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Telefono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your telefono';
                  }
                  if (!_phoneRegExp.hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _anoNacimientoController,
                decoration: const InputDecoration(labelText: 'Ano Nacimiento'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ano nacimiento';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > maxYear) {
                    return 'Please enter a valid year (1900-$maxYear)';
                  }
                  if (year > minYear) {
                    return 'User must be at least 12 years old';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              ElevatedButton(
                onPressed: _isSubmitted ? null : _submitForm,
                child: const Text('ENVIAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModifyUserPage extends StatefulWidget {
  const ModifyUserPage({super.key});

  @override
  State<ModifyUserPage> createState() => _ModifyUserPageState();
}

class _ModifyUserPageState extends State<ModifyUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nickController = TextEditingController();
  final _nombreController = TextEditingController();
  final _primerApellidoController = TextEditingController();
  final _segundoApellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _anoNacimientoController = TextEditingController();
  bool _isSubmitted = false;
  Map<String, dynamic> user = {};

  final RegExp _emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final RegExp _phoneRegExp = RegExp(r"^\+?[1-9]\d{1,14}$");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userMap =
          ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>;
      final castedUserMap = Map<String, dynamic>.from(userMap);
      castedUserMap['apellido2'] ??= '-';
      setState(() {
        user = castedUserMap;
        _nickController.text = user['nick'];
        _nombreController.text = user['nombre'];
        _primerApellidoController.text = user['apellido1'];
        _segundoApellidoController.text = user['apellido2'];
        _emailController.text = user['email'];
        _telefonoController.text = user['movil'];
        _anoNacimientoController.text = user['ano_nacimiento'];
      });
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitted = true;
      });
      final usuarioData = {
        'user_id': user['id'],
        'action': 'updateuser',
        'nick': _nickController.text,
        'nombre': _nombreController.text,
        'apellido1': _primerApellidoController.text,
        'apellido2': _segundoApellidoController.text,
        'email': _emailController.text,
        'movil': _telefonoController.text,
        'ano_nacimiento': _anoNacimientoController.text,
      };

      final url = Uri.parse(
          'https://container-134012752825.europe-southwest1.run.app/usuarios/');
      final response = await http.put(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(usuarioData));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario modificado correctamente')),
        );
        //Reload user data after modification
        final updatedUser = await _fetchUser(user['id']);
        if(updatedUser != null){
          Navigator.pop(context);
          //Instead of refreshing the entire user list, refresh only the specific user details
          Navigator.pushReplacementNamed(context, '/userDetails', arguments: updatedUser);
          //Refresh the user list in MyHomePage
          final myHomePageState = context.findAncestorStateOfType<_MyHomePageState>();
          if(myHomePageState != null){
            myHomePageState._fetchUsers();
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchUser(String userId) async {
    try {
      final usuarioData = {
        'action': 'getuser',
        'user_id': userId,
      };

      final response = await http.post(
        Uri.parse(
            'https://container-134012752825.europe-southwest1.run.app/usuarios'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(usuarioData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user: ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minYear = now.year - 12;
    final maxYear = now.year;

    return Scaffold(
      appBar: AppBar(title: const Text('Modificar Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nickController,
                decoration: const InputDecoration(labelText: 'Nick'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nick';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nombre';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _primerApellidoController,
                decoration: const InputDecoration(labelText: 'Primer Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your primer apellido';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _segundoApellidoController,
                decoration:
                    const InputDecoration(labelText: 'Segundo Apellido'),
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!_emailRegExp.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Telefono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your telefono';
                  }
                  if (!_phoneRegExp.hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              TextFormField(
                controller: _anoNacimientoController,
                decoration: const InputDecoration(labelText: 'Ano Nacimiento'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ano nacimiento';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > maxYear) {
                    return 'Please enter a valid year (1900-$maxYear)';
                  }
                  if (year > minYear) {
                    return 'User must be at least 12 years old';
                  }
                  return null;
                },
                readOnly: _isSubmitted,
              ),
              ElevatedButton(
                onPressed: _isSubmitted ? null : _submitForm,
                child: const Text('ENVIAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
