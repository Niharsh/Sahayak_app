import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/provider_service.dart';

class ProviderStatus extends StatefulWidget {
  @override
  _ProviderStatusState createState() => _ProviderStatusState();
}

class _ProviderStatusState extends State<ProviderStatus> {
  Map<String, dynamic>? provider;
  bool loading = true;

  Future<void> load() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = ProviderService(auth.token!);
    final res = await service.getMe();
    setState(() {
      loading = false;
      if (res['status'] == 200) provider = res['body']['provider'];
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
      appBar: AppBar(title: Text('Provider Status')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : provider == null
              ? Center(child: Text('No provider profile.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Service Category: ${provider!['serviceCategory'] ?? '-'}'),
                    SizedBox(height: 8),
                    Text('Service Areas: ${(provider!['serviceAreas'] ?? []).join(', ')}'),
                    SizedBox(height: 8),
                    Text('Experience: ${provider!['experienceYears'] ?? '-'} years'),
                    SizedBox(height: 8),
                    Text('Verification Level: ${provider!['verificationLevel'] ?? 0}'),
                    SizedBox(height: 8),
                    Text('Identity status: ${provider!['verification']?['identity']?['status'] ?? '-'}'),
                    Text('Skill status: ${provider!['verification']?['skill']?['status'] ?? '-'}'),
                    SizedBox(height: 16),
                    provider!['documents'] != null
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: (provider!['documents'] as List).length,
                              itemBuilder: (context, index) {
                                final d = provider!['documents'][index];
                                return ListTile(title: Text(d['filename'] ?? d['path'].split('/').last), subtitle: Text(d['type'] ?? ''));
                              },
                            ),
                          )
                        : Text('No documents'),
                  ]),
                ),
    );
  }
}
