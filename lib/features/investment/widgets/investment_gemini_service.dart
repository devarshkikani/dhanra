import 'dart:convert';
import 'package:http/http.dart' as http;

class InvestmentGeminiService {
  // Use the correct Gemini AI endpoint and API key
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String _apiKey = 'AIzaSyDqAq9hSVA-PPO9pUlh5ov_XJBHJn2Etjo';

  static Future<List<String>> fetchRecentOpportunities(
      String optionName) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': _apiKey,
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Show me the latest investment opportunities for $optionName in India, with a short description."
              }
            ]
          }
        ]
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] is List) {
        // Each candidate may have a content.parts[0].text
        return (data['candidates'] as List).expand<String>((c) {
          final parts = c['content']?['parts'] as List?;
          if (parts != null && parts.isNotEmpty && parts[0]['text'] != null) {
            // Split by newlines or bullets if needed
            return parts[0]['text']
                .toString()
                .split(RegExp(r'\n|•'))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty);
          }
          return [];
        }).toList();
      }
      return [];
    } else {
      throw Exception('Failed to fetch opportunities: ${response.body}');
    }
  }
}
