import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:p_hn25/app/core/constants/api_keys.dart';

void main() async {
  final requestBody = {
    "system_instruction": {
      "role": "system",
      "parts": [{"text": "Eres un asistente de salud virtual."}]
    },
    "contents": [
      {"role": "user", "parts": [{"text": "Hola"}]}
    ]
  };
  
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey');
  final response = await http.post(
    url, 
    headers: {'Content-Type': 'application/json'}, 
    body: json.encode(requestBody)
  );
  print('Status: ${response.statusCode}');
  print('Body length: ${response.body.length}');
  print(response.body);
}
