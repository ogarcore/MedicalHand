import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:p_hn25/app/core/constants/api_keys.dart';

void main() async {
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$geminiApiKey');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    final models = decoded['models'] as List;
    for (var m in models) {
      final name = m['name'];
      final supportedGenerationMethods = m['supportedGenerationMethods'];
      if (supportedGenerationMethods != null && supportedGenerationMethods.contains('generateContent')) {
        print(name);
      }
    }
  } else {
    print('Failed: ${response.statusCode}');
    print(response.body);
  }
}
