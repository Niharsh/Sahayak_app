import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/empty_state.dart';

class ProviderBookingsScreen extends StatefulWidget {
  @override
  _ProviderBookingsScreenState createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  List bookings = [];
  bool loading = true;

  Future<void> load() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = BookingService(auth.token!);
    final res = await service.getMyBookings(auth.token!);
    setState(() {
      loading = false;
      if (res['status'] == 200) bookings = res['body']['bookings'];
    });
  }

  Future<void> acceptBooking(String id) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = BookingService(auth.token!);
    final res = await service.acceptBooking(id, auth.token!);
    if (res['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Accepted')));
      await load();
    } else {
      final msg = res['body']?['error'] ?? 'Failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> rejectBooking(String id) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = BookingService(auth.token!);
    final res = await service.rejectBooking(id, auth.token!);
    if (res['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rejected')));
      await load();
    } else {
      final msg = res['body']?['error'] ?? 'Failed';
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
      appBar: AppBar(title: Text('Incoming Bookings')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? EmptyState(title: 'No incoming bookings', subtitle: 'You will see requests here when clients book your service', icon: Icons.inbox)
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.12), child: Icon(Icons.build, color: Theme.of(context).colorScheme.secondary)),
                        title: Text('Service: ${b['serviceCategory']}', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Client: ${b['client'] != null ? b['client']['name'] ?? '' : ''}'),
                        trailing: Column(mainAxisSize: MainAxisSize.min, children: [StatusBadge(status: b['status']), if (b['status'] == 'pendingAcceptance') SizedBox(height: 6), if (b['status'] == 'pendingAcceptance') Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: Icon(Icons.play_arrow, color: Colors.green), onPressed: () => acceptBooking(b['_id'])), IconButton(icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error), onPressed: () => rejectBooking(b['_id']))])]),
                        onTap: () => Navigator.pushNamed(context, '/booking/detail', arguments: {'booking': b}),
                      ),
                    );
                  },
                ),
    );
  }
}
