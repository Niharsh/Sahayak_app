import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import '../services/provider_service.dart';
import '../data/categories.dart';
import '../widgets/location_autocomplete_field.dart';

class ProviderApplyScreen extends StatefulWidget {
  @override
  _ProviderApplyScreenState createState() => _ProviderApplyScreenState();
}

class _ProviderApplyScreenState extends State<ProviderApplyScreen> {
  String? _selectedCategoryLabel;
  final _expCtrl = TextEditingController();
  List<File> identityFiles = [];
  List<File> skillFiles = [];
  bool loading = false;
  // selected areas stored as normalized lowercase values
  List<String> _selectedAreasNormalized = [];

  Future<void> pickFiles(List<File> target) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        target.addAll(result.paths.map((p) => File(p!)));
      });
    }
  }

  Future<void> submit() async {
    if (_selectedCategoryLabel == null || _selectedCategoryLabel!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a service category')));
      return;
    }
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = ProviderService(auth.token!);
    // normalize category value to send
    final categoryValue = valueForLabel(_selectedCategoryLabel!);
    // ensure some areas selected
    if (_selectedAreasNormalized.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please add at least one service area from suggestions')));
      setState(() => loading = false);
      return;
    }

    final fields = {'serviceCategory': categoryValue, 'serviceAreas': _selectedAreasNormalized, 'experienceYears': int.tryParse(_expCtrl.text) ?? 0};
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
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Service Category'),
              value: _selectedCategoryLabel,
              items: CATEGORY_LABELS.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _selectedCategoryLabel = v),
            ),
            // Select one or more locations from suggestions. Free-text not allowed.
            LocationAutocompleteField(
              multi: true,
              onChanged: (list) => setState(() => _selectedAreasNormalized = List<String>.from(list)),
              hintText: 'Add service areas (pick from suggestions)',
            ),
            SizedBox(height: 6),
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
