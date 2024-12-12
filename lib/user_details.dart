import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  Map<String, dynamic>? _user; 

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
        Navigator.pop(context); 
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
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userId = user['id'];
    final fetchedUser = await _fetchUser(userId);
    setState(() {
      _user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator()); 
    }

    final user = _user!;
    final userId = user['id'];
    final imageUrl = user['imageUrl']; 

    return Scaffold(
      appBar: AppBar(title: Text('User Details: ${user['nick']}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null, 
              child: imageUrl == null || imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),

            Text(
              user['nick'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              '${user['nombre']} ${user['apellido1']} ${user['apellido2']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

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

            Column(
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/newWorkout');
                  },
                  child: const Text('Nuevo entrenamiento'),
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
  final VoidCallback? onUserAdded; 

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
        widget.onUserAdded?.call(); 
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
        final updatedUser = await _fetchUser(user['id']);
        if(updatedUser != null){
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/userDetails', arguments: updatedUser);
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
