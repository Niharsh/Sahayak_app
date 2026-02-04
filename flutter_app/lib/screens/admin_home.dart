import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Admin Home')),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Admin Dashboard'), SizedBox(height: 10), ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/admin/providers'), child: Text('Pending Providers')), SizedBox(height: 20), ElevatedButton(onPressed: () async { await auth.logout(); Navigator.pushReplacementNamed(context, '/login'); }, child: Text('Logout'))])),
    );
  }
}
