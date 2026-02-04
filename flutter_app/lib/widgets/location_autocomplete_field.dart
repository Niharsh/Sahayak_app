import 'dart:async';
import 'package:flutter/material.dart';
import '../services/location_service.dart';

String _displayLabel(String normalized) {
  if (normalized.isEmpty) return '';
  final s = normalized.trim();
  return s[0].toUpperCase() + s.substring(1);
}

class LocationAutocompleteField extends StatefulWidget {
  final bool multi;
  final List<String>? initialSelected; // list of normalized values
  final Function(String normalized)? onSelected; // single select
  final Function(List<String> normalized)? onChanged; // multi
  final String hintText;

  const LocationAutocompleteField({
    Key? key,
    this.multi = false,
    this.initialSelected,
    this.onSelected,
    this.onChanged,
    this.hintText = 'Start typing location',
  }) : super(key: key);

  @override
  _LocationAutocompleteFieldState createState() => _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  final _ctrl = TextEditingController();
  final _service = LocationService();
  Timer? _debounce;
  List<String> _suggestions = [];
  bool _loading = false;


  // for multi mode
  List<String> _selected = [];

  @override
  void initState() {
    super.initState();
    if (widget.multi && widget.initialSelected != null) {
      _selected = List<String>.from(widget.initialSelected!);
    }
  }

  void _onChanged(String v) {
    // typing forces selection from suggestions
    if (v.trim().length < 1) {
      setState(() => _suggestions = []);
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _loading = true);
      final res = await _service.search(v.trim());
      setState(() {
        _suggestions = res;
        _loading = false;
      });
    });
  }

  void _selectSuggestion(String normalized) {
    final display = _displayLabel(normalized);
    if (widget.multi) {
      if (!_selected.contains(normalized)) {
        setState(() {
          _selected.add(normalized);
        });
        widget.onChanged?.call(_selected);
      }
      _ctrl.clear();
      setState(() => _suggestions = []);
    } else {
      setState(() {
        _ctrl.text = display;
        _suggestions = [];
      });
      widget.onSelected?.call(normalized);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.multi)
          Wrap(
            spacing: 6,
            runSpacing: -8,
            children: _selected
                .map((s) => Chip(
                      label: Text(_displayLabel(s)),
                      onDeleted: () {
                        setState(() => _selected.remove(s));
                        widget.onChanged?.call(_selected);
                      },
                    ))
                .toList(),
          ),
        TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            labelText: widget.hintText,
            suffixIcon: _loading ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : null,
          ),
          onChanged: _onChanged,
          onTap: () {
            // clear suggestions when tapping
            if (_ctrl.text.trim().length >= 1) _onChanged(_ctrl.text);
          },
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, idx) {
                final n = _suggestions[idx];
                return ListTile(
                  title: Text(_displayLabel(n)),
                  onTap: () => _selectSuggestion(n),
                );
              },
            ),
          )
      ],
    );
  }
}
