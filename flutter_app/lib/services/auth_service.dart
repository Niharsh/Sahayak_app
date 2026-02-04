import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api.dart';

class AuthService extends ChangeNotifier {
  final storage = FlutterSecureStorage();
  String? _token;
  String? userRole;

  Future<bool> tryAutoLogin() async {
    final token = await storage.read(key: 'jwt');
    if (token == null) return false;
    _token = token;
    // call /auth/me
    final resp = await http.get(Uri.parse('$BASE_URL/auth/me'), headers: {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    });
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      userRole = data['user']['role'];
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await http.post(Uri.parse('$BASE_URL/auth/login'), headers: {'Content-Type': 'application/json'}, body: json.encode({'email': email, 'password': password}));
    final data = json.decode(resp.body);
    if (resp.statusCode == 200) {
      _token = data['token'];
      userRole = data['user']['role'];
      await storage.write(key: 'jwt', value: _token);
      notifyListeners();
    }
    return {'status': resp.statusCode, 'body': data};
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final resp = await http.post(Uri.parse('$BASE_URL/auth/register'), headers: {'Content-Type': 'application/json'}, body: json.encode({'name': name, 'email': email, 'password': password, 'role': role}));
    final data = json.decode(resp.body);
    if (resp.statusCode == 201) {
      _token = data['token'];
      userRole = data['user']['role'];
      await storage.write(key: 'jwt', value: _token);
      notifyListeners();
    }
    return {'status': resp.statusCode, 'body': data};
  }

  Future<void> logout() async {
    _token = null;
    userRole = null;
    await storage.delete(key: 'jwt');
    notifyListeners();
  }

  String? get token => _token;
}
