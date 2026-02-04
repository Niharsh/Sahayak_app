import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  void _submit() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final res = await auth.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    setState(() => _loading = false);
    if (res['status'] == 200) {
      final role = auth.userRole;
      if (role == 'client') Navigator.pushReplacementNamed(context, '/client');
      if (role == 'provider') Navigator.pushReplacementNamed(context, '/provider');
      if (role == 'admin') Navigator.pushReplacementNamed(context, '/admin');
    } else {
      final msg = res['body']?['error'] ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            _loading ? CircularProgressIndicator() : ElevatedButton(onPressed: _submit, child: Text('Login')),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: Text('Register'))
          ],
        ),
      ),
    );
  }
}
