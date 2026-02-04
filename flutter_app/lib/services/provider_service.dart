import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api.dart';

class ProviderService {
  final String token;
  ProviderService(this.token);

  Future<Map<String, dynamic>> apply(Map<String, dynamic> fields, {List<File>? identityFiles, List<File>? skillFiles}) async {
    final uri = Uri.parse('$BASE_URL/providers/apply');
    final req = http.MultipartRequest('POST', uri);
    req.headers['Authorization'] = 'Bearer $token';

    // fields
    fields.forEach((k, v) {
      if (v is List) {
        req.fields[k] = json.encode(v);
      } else {
        req.fields[k] = v.toString();
      }
    });

    if (identityFiles != null) {
      for (var f in identityFiles) {
        req.files.add(await http.MultipartFile.fromPath('identity', f.path));
      }
    }
    if (skillFiles != null) {
      for (var f in skillFiles) {
        req.files.add(await http.MultipartFile.fromPath('skill', f.path));
      }
    }

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> getMe() async {
    final resp = await http.get(Uri.parse('$BASE_URL/providers/me'), headers: {'Authorization': 'Bearer $token'});
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> fields, {List<File>? identityFiles, List<File>? skillFiles}) async {
    final uri = Uri.parse('$BASE_URL/providers/me');
    final req = http.MultipartRequest('PUT', uri);
    req.headers['Authorization'] = 'Bearer $token';

    fields.forEach((k, v) {
      if (v is List) {
        req.fields[k] = json.encode(v);
      } else {
        req.fields[k] = v.toString();
      }
    });

    if (identityFiles != null) {
      for (var f in identityFiles) {
        req.files.add(await http.MultipartFile.fromPath('identity', f.path));
      }
    }
    if (skillFiles != null) {
      for (var f in skillFiles) {
        req.files.add(await http.MultipartFile.fromPath('skill', f.path));
      }
    }

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    return {'status': resp.statusCode, 'body': json.decode(resp.body)};
  }
}
