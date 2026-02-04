import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../data/categories.dart';
import 'provider_list.dart';

class ClientHome extends StatefulWidget {
  @override
  _ClientHomeState createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  String? _selectedCategoryLabel;
  final _areaCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Client Home')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(
            color: Theme.of(context).primaryColor.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.handyman, size: 48, color: Theme.of(context).primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Find help for home services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(height: 6),
                        Text('Trusted professionals for cleaning, repairs & more'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('Discover Services', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Service Category'),
            value: _selectedCategoryLabel,
            items: CATEGORY_LABELS.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (v) => setState(() => _selectedCategoryLabel = v),
          ),
          SizedBox(height: 8),
          TextField(controller: _areaCtrl, decoration: InputDecoration(labelText: 'Area (e.g., Area1)')),
          SizedBox(height: 12),
          ElevatedButton(onPressed: () {
            final cat = _selectedCategoryLabel;
            final area = _areaCtrl.text.trim();
            if (cat != null && cat.isNotEmpty && area.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderListScreen(category: valueForLabel(cat), area: area.trim().toLowerCase())));
          }, child: Text('Search Providers')),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/client/bookings'), child: Text('My Bookings')),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () async { await auth.logout(); Navigator.pushReplacementNamed(context, '/login'); }, child: Text('Logout'))
        ]),
      ),
    );
  }
}
