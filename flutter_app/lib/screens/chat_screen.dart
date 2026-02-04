import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> messages = [];
  String bookingId = '';
  bool loading = false;
  String status = '';
  Timer? timer;
  final TextEditingController _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) bookingId = args['bookingId'] ?? '';
    _startPolling();
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startPolling() {
    _fetchAll();
    timer = Timer.periodic(Duration(seconds: 3), (_) => _fetchAll());
  }

  Future<void> _fetchAll() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.token == null) return;
    await _loadMessages(auth.token!);
    await _loadBookingStatus(auth.token!);
  }

  Future<void> _loadMessages(String token) async {
    final svc = BookingService(token);
    final res = await svc.getMessages(bookingId, token);
    if (res['status'] == 200) {
      setState(() => messages = res['body']['messages']);
    }
  }

  Future<void> _loadBookingStatus(String token) async {
    final svc = BookingService(token);
    final res = await svc.getMyBookings(token);
    if (res['status'] == 200) {
      final list = res['body']['bookings'] as List;
      final b = list.firstWhere((it) => it['_id'] == bookingId, orElse: () => null);
      if (b != null) setState(() => status = b['status']);
    }
  }

  Future<void> _sendMessage() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final svc = BookingService(auth.token!);
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    setState(() => loading = true);
    final res = await svc.sendMessage(bookingId, auth.token!, content);
    setState(() => loading = false);
    if (res['status'] == 200) {
      _controller.clear();
      await _loadMessages(auth.token!);
    } else {
      final msg = res['body']?['error'] ?? 'Failed to send';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = status == 'accepted' || status == 'inProgress';
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            reverse: false,
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages[i];
              final sender = m['sender'];
              final senderName = sender != null ? (sender['name'] ?? sender['email'] ?? sender['_id'] ?? 'User') : (m['senderId'] ?? 'User');
              final content = m['content'] ?? '';
              final time = m['createdAt'] ?? '';
              return ListTile(
                title: Text(senderName),
                subtitle: Text(content),
                trailing: Text(time.toString().split('.')[0]),
              );
            },
          ),
        ),
        if (!canSend)
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.grey[200],
            child: Row(children: [Icon(Icons.chat_bubble_outline), SizedBox(width: 8), Expanded(child: Text('Chat is read-only until a provider accepts the job.'))]),
          ),
        if (canSend)
          SafeArea(
            child: Row(children: [
              Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: 'Type a message'))),
              loading
                  ? Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())
                  : IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
            ]),
          ),
      ]),
    );
  }
}
