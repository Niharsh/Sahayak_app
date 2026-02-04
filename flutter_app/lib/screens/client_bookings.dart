import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/empty_state.dart';

class ClientBookingsScreen extends StatefulWidget {
  @override
  _ClientBookingsScreenState createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen> {
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

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Bookings')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? EmptyState(title: 'No bookings yet', subtitle: 'You can book a service from the home screen', icon: Icons.calendar_today)
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.build, color: Theme.of(context).primaryColor),
                        title: Text('${b['serviceCategory']}', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${b['serviceArea']}'), SizedBox(height: 4), Text('${b['schedule'] != null ? DateTime.parse(b['schedule']).toLocal().toString().split('.').first : ''}')]),
                        trailing: Column(mainAxisSize: MainAxisSize.min, children: [StatusBadge(status: b['status']), SizedBox(height: 6), IconButton(icon: Icon(Icons.chat), onPressed: () => Navigator.pushNamed(context, '/booking/chat', arguments: {'bookingId': b['_id']}))]),
                        onTap: () => Navigator.pushNamed(context, '/booking/detail', arguments: {'booking': b}),
                      ),
                    );
                  },
                ),
    );
  }
}
