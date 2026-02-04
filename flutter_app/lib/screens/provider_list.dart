import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../widgets/empty_state.dart';

class ProviderListScreen extends StatefulWidget {
  final String category;
  final String area;
  ProviderListScreen({required this.category, required this.area});

  @override
  _ProviderListScreenState createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  List providers = [];
  bool loading = true;

  Future<void> load() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = BookingService(auth.token!);
    final res = await service.searchProviders(widget.category, widget.area);
    setState(() {
      loading = false;
      if (res['status'] == 200) providers = res['body']['providers'];
    });
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Providers')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : providers.isEmpty
              ? EmptyState(title: 'No providers found', subtitle: 'Try a different category or area', icon: Icons.search)
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final p = providers[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.15), child: Icon(Icons.handyman, color: Theme.of(context).colorScheme.secondary)),
                        title: Text(p['name'] ?? 'Unnamed', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${p['serviceCategory'] ?? ''} • ${(p['serviceAreas'] ?? []).join(', ')}'),
                        trailing: Column(mainAxisSize: MainAxisSize.min, children: [Text('Lv ${p['verificationLevel']}'), Icon(Icons.verified, color: p['verificationLevel'] >= 2 ? Colors.green : Colors.grey)]),
                        onTap: () => Navigator.pushNamed(context, '/client/booking/create', arguments: {'providerId': p['id'], 'category': p['serviceCategory'], 'area': (p['serviceAreas'] ?? []).first}),
                      ),
                    );
                  },
                ),
    );
  }
}
