import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';

class BookingCreateScreen extends StatefulWidget {
  @override
  _BookingCreateScreenState createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends State<BookingCreateScreen> {
  String? providerId;
  String? category;
  String? area;
  DateTime? schedule;
  bool loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      providerId = args['providerId'];
      category = args['category'];
      area = args['area'];
    }
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: DateTime(now.year + 1));
    if (d != null) {
      final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: 9, minute: 0));
      if (t != null) setState(() => schedule = DateTime(d.year, d.month, d.day, t.hour, t.minute));
    }
  }

  Future<void> submit() async {
    if (schedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please pick schedule')));
      return;
    }
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = BookingService(auth.token!);
    final payload = {'serviceCategory': category, 'serviceArea': area, 'schedule': schedule!.toIso8601String(), 'providerId': providerId};
    final res = await service.createBooking(payload, auth.token!);
    setState(() => loading = false);
    if (res['status'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking created')));
      Navigator.pushReplacementNamed(context, '/client/bookings');
    } else {
      final msg = res['body']?['error'] ?? 'Failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Provider: ${providerId ?? '-'}'),
          SizedBox(height: 8),
          Text('Category: ${category ?? '-'}'),
          SizedBox(height: 8),
          Text('Area: ${area ?? '-'}'),
          SizedBox(height: 16),
          Text(schedule == null ? 'No schedule chosen' : 'Scheduled at: ${schedule.toString()}'),
          SizedBox(height: 10),
          ElevatedButton(onPressed: pickDate, child: Text('Pick date & time')),
          SizedBox(height: 20),
          loading ? Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: submit, child: Text('Confirm Booking'))
        ]),
      ),
    );
  }
}
