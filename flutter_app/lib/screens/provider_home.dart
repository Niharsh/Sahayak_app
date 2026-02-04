import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProviderHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Provider Home')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(
            color: Theme.of(context).primaryColor.withOpacity(0.06),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.handyman, size: 48, color: Theme.of(context).primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Provider Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(height: 6),
                        Text('Manage your profile and incoming bookings'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/provider/apply'), child: Text('Apply / Edit Profile')),
          SizedBox(height: 10),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/provider/status'), child: Text('Provider Status')),
          SizedBox(height: 10),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/provider/bookings'), child: Text('Incoming Bookings')),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () async { await auth.logout(); Navigator.pushReplacementNamed(context, '/login'); }, child: Text('Logout'))
        ]),
      ),
    );
  }
}
