import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'client';
  bool _loading = false;

  void _submit() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final res = await auth.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text.trim(), _role);
    setState(() => _loading = false);
    if (res['status'] == 201) {
      if (_role == 'client') Navigator.pushReplacementNamed(context, '/client');
      if (_role == 'provider') Navigator.pushReplacementNamed(context, '/provider');
      if (_role == 'admin') Navigator.pushReplacementNamed(context, '/admin');
    } else {
      final msg = res['body']?['error'] ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 10),
            Text('Select role:'),
            DropdownButton<String>(value: _role, onChanged: (val) => setState(() => _role = val ?? 'client'), items: [DropdownMenuItem(child: Text('Client'), value: 'client'), DropdownMenuItem(child: Text('Provider'), value: 'provider'), DropdownMenuItem(child: Text('Admin'), value: 'admin')]),
            SizedBox(height: 20),
            _loading ? Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submit, child: Text('Register')),
          ],
        ),
      ),
    );
  }
}
