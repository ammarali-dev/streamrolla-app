import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://public.streamrolla.com/api/discovery/websites';

  static Future<List<String>> fetchDomains() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == 'success') {
          return List<String>.from(body['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching domains: $e');
      return [];
    }
  }
}
