import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api.dart';
import 'package:http/http.dart' as http;

class AdminProvidersScreen extends StatefulWidget {
  @override
  _AdminProvidersScreenState createState() => _AdminProvidersScreenState();
}

class _AdminProvidersScreenState extends State<AdminProvidersScreen> {
  List providers = [];
  bool loading = true;

  Future<void> load() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final resp = await http.get(Uri.parse('$BASE_URL/admin/providers?status=pending'), headers: {'Authorization': 'Bearer ${auth.token}'});
    setState(() {
      loading = false;
      if (resp.statusCode == 200) providers = json.decode(resp.body)['providers'];
    });
  }

  Future<void> action(String providerId, String endpoint, String action) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final resp = await http.post(Uri.parse('$BASE_URL/admin/providers/$providerId/$endpoint'), headers: {'Authorization': 'Bearer ${auth.token}', 'Content-Type': 'application/json'}, body: json.encode({'action': action}));
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated')));
      await load();
    } else {
      final msg = json.decode(resp.body)['error'] ?? 'Failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pending Providers')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final p = providers[index];
                return ListTile(
                  title: Text(p['user']?['name'] ?? 'Unknown'),
                  subtitle: Text('Service: ${p['serviceCategory'] ?? '-'} • Level: ${p['verificationLevel'] ?? 0}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: Icon(Icons.check), onPressed: () => action(p['_id'], 'verify-identity', 'approve')),
                    IconButton(icon: Icon(Icons.close), onPressed: () => action(p['_id'], 'verify-identity', 'reject')),
                    IconButton(icon: Icon(Icons.school), onPressed: () => action(p['_id'], 'verify-skill', 'approve')),
                    IconButton(icon: Icon(Icons.block), onPressed: () => action(p['_id'], 'verify-skill', 'reject')),
                  ]),
                );
              },
            ),
    );
  }
}
