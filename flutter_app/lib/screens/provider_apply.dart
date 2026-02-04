import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import '../services/provider_service.dart';

class ProviderApplyScreen extends StatefulWidget {
  @override
  _ProviderApplyScreenState createState() => _ProviderApplyScreenState();
}

class _ProviderApplyScreenState extends State<ProviderApplyScreen> {
  final _categoryCtrl = TextEditingController();
  final _areasCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  List<File> identityFiles = [];
  List<File> skillFiles = [];
  bool loading = false;

  Future<void> pickFiles(List<File> target) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        target.addAll(result.paths.map((p) => File(p!)));
      });
    }
  }

  Future<void> submit() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = ProviderService(auth.token!);
    final fields = {'serviceCategory': _categoryCtrl.text.trim(), 'serviceAreas': _areasCtrl.text.split(',').map((s) => s.trim()).toList(), 'experienceYears': int.tryParse(_expCtrl.text) ?? 0};
    final res = await service.apply(fields, identityFiles: identityFiles, skillFiles: skillFiles);
    setState(() => loading = false);
    if (res['status'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Application submitted')));
      Navigator.pushReplacementNamed(context, '/provider/status');
    } else {
      final msg = res['body']?['error'] ?? 'Apply failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Provider Application')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _categoryCtrl, decoration: InputDecoration(labelText: 'Service Category (e.g., plumber)')),
            TextField(controller: _areasCtrl, decoration: InputDecoration(labelText: 'Service Areas (comma separated)')),
            TextField(controller: _expCtrl, decoration: InputDecoration(labelText: 'Years of experience'), keyboardType: TextInputType.number),
            SizedBox(height: 10),
            Text('Identity documents'),
            Wrap(children: identityFiles.map((f) => Chip(label: Text(f.path.split('/').last))).toList()),
            Row(children: [ElevatedButton(onPressed: () => pickFiles(identityFiles), child: Text('Attach'))]),
            SizedBox(height: 10),
            Text('Skill documents'),
            Wrap(children: skillFiles.map((f) => Chip(label: Text(f.path.split('/').last))).toList()),
            Row(children: [ElevatedButton(onPressed: () => pickFiles(skillFiles), child: Text('Attach'))]),
            SizedBox(height: 20),
            loading ? Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: submit, child: Text('Submit'))
          ],
        ),
      ),
    );
  }
}
