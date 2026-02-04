import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api.dart';

class BookingService {
  final String token;
  BookingService(this.token);

  Future<Map<String, dynamic>> getCategories() async {
    final resp = await http.get(Uri.parse('$BASE_URL/services/categories'));
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> searchProviders(String category, String area) async {
    final resp = await http.get(Uri.parse('$BASE_URL/providers/search?category=$category&area=$area'));
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> payload, String token) async {
    final resp = await http.post(Uri.parse('$BASE_URL/bookings'), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: json.encode(payload));
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> getMyBookings(String token) async {
    final resp = await http.get(Uri.parse('$BASE_URL/bookings/me'), headers: {'Authorization': 'Bearer $token'});
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> acceptBooking(String id, String token) async {
    final resp = await http.post(Uri.parse('$BASE_URL/bookings/$id/accept'), headers: {'Authorization': 'Bearer $token'});
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> rejectBooking(String id, String token) async {
    final resp = await http.post(Uri.parse('$BASE_URL/bookings/$id/reject'), headers: {'Authorization': 'Bearer $token'});
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> startBooking(String id, String token) async {
    final resp = await http.post(Uri.parse('$BASE_URL/bookings/$id/start'), headers: {'Authorization': 'Bearer $token'});
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> completeBooking(String id, String token) async {
    final resp = await http.post(Uri.parse('$BASE_URL/bookings/$id/complete'), headers: {'Authorization': 'Bearer $token'});
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> confirmBooking(String id, String token) async {
    final resp = await http.post(Uri.parse('$BASE_URL/bookings/$id/confirm'), headers: {'Authorization': 'Bearer $token'});
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> cancelBooking(String id, String token) async {
    final resp = await http.post(Uri.parse('$BASE_URL/bookings/$id/cancel'), headers: {'Authorization': 'Bearer $token'});
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> getMessages(String bookingId, String token) async {
    final resp = await http.get(Uri.parse('$BASE_URL/bookings/$bookingId/messages'), headers: {'Authorization': 'Bearer $token'});
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> sendMessage(String bookingId, String token, String content) async {
    final resp = await http.post(Uri.parse('$BASE_URL/bookings/$bookingId/messages'), headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: json.encode({'content': content}));
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }
}

