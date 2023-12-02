import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<dynamic>> getItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/list'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      throw Exception('Failed to load items: $e');
    }
  }

  Future<void> addItem(String username, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'text': text,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add item');
      }
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }
}
