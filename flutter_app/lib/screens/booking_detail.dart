import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../widgets/status_badge.dart';

class BookingDetailScreen extends StatefulWidget {
  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? booking;
  bool loading = false;

  Future<void> loadFresh() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = BookingService(auth.token!);
    final res = await service.getMyBookings(auth.token!);
    if (res['status'] == 200) {
      final list = res['body']['bookings'] as List;
      final id = booking?['_id'];
      final fresh = list.firstWhere((b) => b['_id'] == id, orElse: () => null);
      setState(() => booking = fresh);
    }
    setState(() => loading = false);
  }

  void _performAction(String action) async {
    if (booking == null) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    final svc = BookingService(auth.token!);
    Map<String, dynamic> res = {};
    setState(() => loading = true);
    if (action == 'start') res = await svc.startBooking(booking!['_id'], auth.token!);
    if (action == 'complete') res = await svc.completeBooking(booking!['_id'], auth.token!);
    if (action == 'confirm') res = await svc.confirmBooking(booking!['_id'], auth.token!);
    setState(() => loading = false);
    if (res['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated')));
      await loadFresh();
    } else {
      final msg = res['body']?['error'] ?? 'Failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) booking = args['booking'];
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final role = auth.userRole;
    return Scaffold(
      appBar: AppBar(title: Text('Booking Details')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : booking == null
              ? Center(child: Text('Booking not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Row(children: [Icon(Icons.build, color: Theme.of(context).primaryColor), SizedBox(width: 8), Text('${booking!['serviceCategory']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))]),
                            StatusBadge(status: booking!['status']),
                          ]),
                          SizedBox(height: 10),
                          Row(children: [Icon(Icons.place, size: 18), SizedBox(width: 6), Text('${booking!['serviceArea']}')]),
                          SizedBox(height: 6),
                          Row(children: [Icon(Icons.schedule, size: 18), SizedBox(width: 6), Text('${booking!['schedule'] ?? ''}')]),
                        ]),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(children: [
                      if (role == 'provider' && booking!['status'] == 'accepted') ElevatedButton.icon(onPressed: () => _performAction('start'), icon: Icon(Icons.play_arrow), label: Text('Start Job')),
                      if (role == 'provider' && booking!['status'] == 'inProgress') ElevatedButton.icon(onPressed: () => _performAction('complete'), icon: Icon(Icons.check), label: Text('Mark Completed')),
                      if (role == 'client' && booking!['status'] == 'completed') ElevatedButton.icon(onPressed: () => _performAction('confirm'), icon: Icon(Icons.done_all), label: Text('Confirm')),
                      SizedBox(width: 8),
                      ElevatedButton.icon(onPressed: (booking!['status'] == 'accepted' || booking!['status'] == 'inProgress') ? () => Navigator.pushNamed(context, '/booking/chat', arguments: {'bookingId': booking!['_id']}) : null, icon: Icon(Icons.chat), label: Text('Chat')),
                      SizedBox(width: 8),
                      OutlinedButton(onPressed: loadFresh, child: Text('Refresh')),
                    ]),
                  ]),
                ),
    );
  }
}
