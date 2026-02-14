import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String baseUrl = "http://10.0.2.2:8000";

  Future<String> getReply(String message) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["reply"];
      } else {
        return "Server error";
      }
    } catch (e) {
      return "Connection failed";
    }
  }
}
