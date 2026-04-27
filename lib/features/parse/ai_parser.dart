import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/parse_result.dart';
import '../../core/secure_storage/key_storage.dart';

class AiParser {
  final KeyStorage _keyStorage = KeyStorage();
  final Map<String, ParseResult> _cache = {};

  Future<ParseResult?> parse(String ocrText, String? imagePath, double confidence) async {
    final key = ocrText.hashCode.toString();
    if (_cache.containsKey(key)) return _cache[key];

    final apiKey = await _keyStorage.getApiKey();
    final enabled = await _keyStorage.isAiModeEnabled();
    final provider = await _keyStorage.getAiProvider();

    if (!enabled || apiKey == null || apiKey.isEmpty || provider != 'OpenAI') return null;

    ParseResult? result;

    // Tier 2: text-only GPT (cheap — no image tokens)
    // Use when confidence is borderline (50–72%) — text is garbled but present
    if (confidence >= 0.50 && confidence < 0.72) {
      result = await _callGptTextOnly(ocrText, apiKey);
      if (result != null) {
         final avgConf = result.confidence.values.reduce((a, b) => a + b) / result.confidence.length;
         if (avgConf >= 0.72) {
           _cache[key] = result;
           return result;
         }
      }
    }

    // Tier 3: vision GPT — only when text tier also fails or confidence is very low
    result = await _callGptVision(ocrText, imagePath, apiKey);
    if (result != null) _cache[key] = result;
    return result;
  }

  Future<ParseResult?> _callGptTextOnly(String ocrText, String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'max_tokens': 300,
          'messages': [
            {
              'role': 'system',
              'content': 'Extract business card fields from OCR text. '
                  'Return only JSON: {name, company, designation, emails:[], phones:[], address, website, linkedInUrl, twitterHandle (can be any social media link), confidence:0.0}. '
                  'Use null for missing fields.',
            },
            {'role': 'user', 'content': ocrText},
          ],
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return null;
    }
  }

  Future<ParseResult?> _callGptVision(String ocrText, String? imagePath, String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    final sendImage = prefs.getBool('send_image_to_ai') ?? false;

    final List<Map<String, dynamic>> contentParts = [];

    if (imagePath != null && sendImage) {
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);
      contentParts.add({
        "type": "image_url",
        "image_url": {
          "url": "data:image/jpeg;base64,$base64Image",
          "detail": "high"
        }
      });
    }

    contentParts.add({
      "type": "text",
      "text": """
Parse this business card. Use both the image AND the OCR text.
OCR text:
$ocrText

Return ONLY valid JSON:
{
  "name": "string or null",
  "designation": "string or null",
  "company": "string or null",
  "phones": ["array of all phones"],
  "emails": ["array of all emails"],
  "website": "string or null",
  "address": "string or null",
  "linkedInUrl": "string or null",
  "twitterHandle": "string or null (can be any social media link)",
  "confidence": 0.0
}
"""
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'max_tokens': 600,
          'messages': [
            {'role': 'system', 'content': 'You are a business card parser. Return ONLY valid JSON.'},
            {'role': 'user', 'content': contentParts}
          ]
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return null;
    }
  }

  ParseResult? _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['choices'][0]['message']['content'] as String;
      final clean = text.replaceAll(RegExp(r'```json|```'), '').trim();
      final Map<String, dynamic> json = jsonDecode(clean);

      final double aiConfidence = (json['confidence'] ?? 0.0).toDouble();
      final confidenceMap = {
        'name': aiConfidence,
        'company': aiConfidence,
        'designation': aiConfidence,
        'phones': aiConfidence,
        'emails': aiConfidence,
        'website': aiConfidence,
        'address': aiConfidence,
        'linkedInUrl': aiConfidence,
        'twitterHandle': aiConfidence,
      };

      return ParseResult(
        name: json['name'],
        company: json['company'],
        designation: json['designation'],
        phones: List<String>.from(json['phones'] ?? []),
        emails: List<String>.from(json['emails'] ?? []),
        website: json['website'],
        address: json['address'],
        linkedInUrl: json['linkedInUrl'],
        twitterHandle: json['twitterHandle'],
        confidence: confidenceMap,
        parseMode: 'ai',
      );
    }
    return null;
  }
}
