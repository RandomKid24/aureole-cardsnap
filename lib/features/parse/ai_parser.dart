import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/models/parse_result.dart';
import '../../core/secure_storage/key_storage.dart';
import '../../core/config/ai_provider_config.dart';
import '../scan/ocr_service.dart';

class AiParser {
  final KeyStorage _keyStorage = KeyStorage();
  final Map<String, ParseResult> _cache = {};

  AiProviderConfig? _lastConfig;
  AiProviderConfig? get lastConfig => _lastConfig;

  static const _timeout = Duration(seconds: 60);
  static const _connectTimeout = Duration(seconds: 15);

  static const _systemPrompt = 'You are an expert at reading business cards. You will be given the OCR output from a business card — a list of text blocks with their approximate font size and position on the card — and optionally the card image itself.\n\nYour job is to figure out what each piece of text represents (name, company, job title, phone, email, address, website, social links) the way a person would if they picked up the card and read it. Use layout, font size, position, and context together — don\'t rely on any single signal alone.\n\nA few things worth keeping in mind (not rigid rules, just useful context):\n- The person\'s name is usually the most prominent text on the card, but not always — ALL CAPS text is not automatically a company. Check whether it has a company suffix (Ltd, LLP, Inc, Pvt Ltd, Technologies, etc.) before deciding it\'s a company.\n- A short phrase directly following or near the name, without a company suffix, is often a job title (CEO, Manager, Director, Founder, etc.), not part of the company name.\n- Cards from India often show a 6-digit PIN code and no US-style ZIP format; state and city names may appear without explicit labels.\n- Company and name blocks are often positioned near each other, but company name can appear above OR below the person\'s name depending on card design — don\'t assume a fixed order.\n- A name can be genuinely absent (e.g. a generic company info card) — don\'t force a name onto a block that\'s actually a company or department name.\n\nThink through the card step by step first: describe briefly what you notice about layout and which block plausibly maps to which field, and why. Then output your final answer as JSON, strictly matching this schema:\n\n{\n  "name": string | null,\n  "company": string | null,\n  "designation": string | null,\n  "phones": string[],\n  "emails": string[],\n  "website": string | null,\n  "address": string | null,\n  "social": { "linkedin": string | null, "other": string[] },\n  "confidence": {\n    "name": number,\n    "company": number,\n    "designation": number,\n    "phones": number,\n    "emails": number,\n    "website": number,\n    "address": number\n  },\n  "reasoning": string\n}\n\nRules for confidence: if a field is genuinely ambiguous or you\'re guessing between two plausible options, give it a LOWER confidence score rather than picking one and reporting high confidence. A low-confidence honest answer is more useful than a wrong confident one — low-confidence fields get reviewed by a human before being saved.\n\nOnly output the JSON object as your final answer, after your reasoning. Do not include markdown code fences around the JSON.';

  static const _fewShotExamples = '\n\n---\n\nExample 1: Standard card (name at top, company below)\n\nOCR blocks:\n  "VIVEK C. ZOPE" | fontSize: 18 | position: top-center\n  "Beforth" | fontSize: 13 | position: below block 1\n  "Software Development & Custom Solutions" | fontSize: 9 | position: below block 2\n  "vivek@beforth.in" | fontSize: 8 | position: bottom-left\n  "+91 98xxxxxxx" | fontSize: 8 | position: bottom-left\n\nReasoning: "VIVEK C. ZOPE" is ALL CAPS but has no company suffix and is positioned at the top in the largest font — classic name placement. "Beforth" has no suffix either, but is smaller, positioned right below the name, and matches a company/brand-name pattern rather than a person\'s name.\n\n{\n  "name": "VIVEK C. ZOPE",\n  "company": "Beforth",\n  "designation": null,\n  "phones": ["+919xxxxxxxx"],\n  "emails": ["vivek@beforth.in"],\n  "website": null,\n  "address": null,\n  "social": {"linkedin": null, "other": []},\n  "confidence": {"name": 0.9, "company": 0.75, "designation": 0.5, "phones": 0.95, "emails": 0.95, "website": 0.5, "address": 0.5},\n  "reasoning": "Name identified by top position, largest font, no company suffix. Company inferred from position and brand-like single-word pattern, moderate confidence since no suffix confirms it."\n}\n\n---\n\nExample 2: Reversed layout (company above name)\n\nOCR blocks:\n  "Infosys Limited" | fontSize: 16 | position: top-center\n  "Rajesh Kumar" | fontSize: 14 | position: below block 1\n  "Senior Technical Lead" | fontSize: 9 | position: below block 2\n  "rajesh.kumar@infosys.com" | fontSize: 8 | position: bottom-left\n  "+91 80 4567xxxx" | fontSize: 8 | position: bottom-left\n  "Electronics City, Hosur Road, Bangalore, Karnataka 560100" | fontSize: 7 | position: bottom-center\n\nReasoning: "Infosys Limited" has a clear company suffix ("Limited") — this is the company. "Rajesh Kumar" is a personal name below. "Senior Technical Lead" is a designation. Address has a PIN code (560100).\n\n{\n  "name": "Rajesh Kumar",\n  "company": "Infosys Limited",\n  "designation": "Senior Technical Lead",\n  "phones": ["+91804567xxxx"],\n  "emails": ["rajesh.kumar@infosys.com"],\n  "website": null,\n  "address": "Electronics City, Hosur Road, Bangalore, Karnataka 560100",\n  "social": {"linkedin": null, "other": []},\n  "confidence": {"name": 0.92, "company": 0.95, "designation": 0.88, "phones": 0.95, "emails": 0.95, "website": 0.5, "address": 0.85},\n  "reasoning": "Company at top with \'Limited\' suffix confirmed. Name is title-case personal name below company. Designation follows name. Address contains Indian PIN code and city/state."\n}\n\n---\n\nExample 3: Designation sandwiched between name and company\n\nOCR blocks:\n  "Priya Sharma" | fontSize: 15 | position: top-left\n  "Co-Founder & CTO" | fontSize: 10 | position: below block 1\n  "Zoho Corporation Pvt. Ltd." | fontSize: 11 | position: below block 2\n  "priya@zohocorp.com" | fontSize: 8 | position: bottom-left\n  "+91 44 6789xxxx" | fontSize: 8 | position: bottom-left\n  "Estella Chapel, 7th Floor, No. 3, Rajiv Gandhi Salai, Chennai, Tamil Nadu 600113" | fontSize: 6 | position: bottom-center\n\nReasoning: "Priya Sharma" is a clear personal name. "Co-Founder & CTO" is a designation (no company suffix, uses "&" and abbreviation). "Zoho Corporation Pvt. Ltd." has multiple company suffixes. Address has a 6-digit PIN code.\n\n{\n  "name": "Priya Sharma",\n  "company": "Zoho Corporation Pvt. Ltd.",\n  "designation": "Co-Founder & CTO",\n  "phones": ["+91446789xxxx"],\n  "emails": ["priya@zohocorp.com"],\n  "website": null,\n  "address": "Estella Chapel, 7th Floor, No. 3, Rajiv Gandhi Salai, Chennai, Tamil Nadu 600113",\n  "social": {"linkedin": null, "other": []},\n  "confidence": {"name": 0.94, "company": 0.95, "designation": 0.9, "phones": 0.95, "emails": 0.95, "website": 0.5, "address": 0.85},\n  "reasoning": "Name is clear title-case personal name. Designation contains role abbreviations (CTO). Company has \'Corporation Pvt. Ltd.\' suffix. Address has 6-digit Indian PIN and Tamil Nadu state."\n}';

  String get _fullPrompt => '$_systemPrompt$_fewShotExamples';

  String _formatBlocks(OcrResult ocrResult) {
    final buffer = StringBuffer();
    buffer.writeln('OCR blocks:');
    for (var i = 0; i < ocrResult.blocks.length; i++) {
      final block = ocrResult.blocks[i];
      final xPct = ocrResult.imageWidth > 0
          ? (block.rect.left / ocrResult.imageWidth * 100).round()
          : 50;
      final yPct = ocrResult.imageHeight > 0
          ? (block.rect.top / ocrResult.imageHeight * 100).round()
          : 50;
      String position;
      if (yPct < 20) {
        if (xPct < 30) {
          position = 'top-left';
        } else if (xPct > 70) {
          position = 'top-right';
        } else {
          position = 'top-center';
        }
      } else if (yPct > 80) {
        if (xPct < 30) {
          position = 'bottom-left';
        } else if (xPct > 70) {
          position = 'bottom-right';
        } else {
          position = 'bottom-center';
        }
      } else {
        if (xPct < 30) {
          position = 'left';
        } else if (xPct > 70) {
          position = 'right';
        } else {
          position = 'center';
        }
      }
      final fontSize = block.rect.height.round();
      buffer.writeln('  "${block.text}" | fontSize: $fontSize | position: $position');
    }
    return buffer.toString();
  }

  Future<ParseResult?> parse(OcrResult ocrResult, String? imagePath, double confidence) async {
    final key = ocrResult.rawText.hashCode.toString();
    if (_cache.containsKey(key)) return _cache[key];

    final config = await _keyStorage.getAiConfig();
    _lastConfig = config;

    if (!config.enabled || config.apiKey.isEmpty) return null;

    ParseResult? result;

    // Tier 1: text-only (cheaper, faster)
    if (confidence >= 0.50 && confidence < 0.72) {
      result = await _callTextModel(config, ocrResult);
      if (result != null) {
        final avgConf = _averageConfidence(result);
        if (avgConf >= 0.72) {
          _cache[key] = result;
          return result;
        }
      }
    }

    // Tier 2: vision (only if provider supports it)
    if (config.supportsVision) {
      result = await _callVisionModel(config, ocrResult, imagePath);
    } else {
      result ??= await _callTextModel(config, ocrResult);
    }

    if (result != null) _cache[key] = result;
    return result;
  }

  double _averageConfidence(ParseResult result) {
    if (result.confidence.isEmpty) return 0.0;
    return result.confidence.values.reduce((a, b) => a + b) / result.confidence.length;
  }

  // ─── OpenAI-compatible format ─────────────────────────────────────

  Future<ParseResult?> _callTextModel(AiProviderConfig config, OcrResult ocrResult) async {
    final blockText = _formatBlocks(ocrResult);
    if (config.format == ApiFormat.gemini) {
      return _callGeminiText(config, blockText);
    }
    return _callOpenAiText(config, blockText);
  }

  Future<ParseResult?> _callVisionModel(AiProviderConfig config, OcrResult ocrResult, String? imagePath) async {
    if (config.format == ApiFormat.gemini) {
      return _callGeminiVision(config, ocrResult, imagePath);
    }
    return _callOpenAiVision(config, ocrResult, imagePath);
  }

  Future<ParseResult?> _callOpenAiText(AiProviderConfig config, String blockText) async {
    try {
      final url = '${config.baseUrl}/chat/completions';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': config.model,
          'max_tokens': 800,
          'messages': [
            {'role': 'system', 'content': _fullPrompt},
            {'role': 'user', 'content': blockText},
          ],
        }),
      ).timeout(_timeout);
      return _processOpenAiResponse(response);
    } catch (_) {
      return null;
    }
  }

  Future<ParseResult?> _callOpenAiVision(AiProviderConfig config, OcrResult ocrResult, String? imagePath) async {
    try {
      final List<Map<String, dynamic>> contentParts = [];
      if (imagePath != null) {
        final imageBytes = await File(imagePath).readAsBytes();
        final base64Image = base64Encode(imageBytes);
        contentParts.add({
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/jpeg;base64,$base64Image',
            'detail': 'high',
          },
        });
      }
      final blockText = _formatBlocks(ocrResult);
      contentParts.add({
        'type': 'text',
        'text': 'Parse this business card. Use both the image AND the OCR text.\n\n$blockText\n\nAnalyze it and return your answer per the system instructions.',
      });

      final url = '${config.baseUrl}/chat/completions';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': config.effectiveVisionModel,
          'max_tokens': 1000,
          'messages': [
            {'role': 'system', 'content': _fullPrompt},
            {'role': 'user', 'content': contentParts},
          ],
        }),
      ).timeout(_timeout);
      return _processOpenAiResponse(response);
    } catch (_) {
      return null;
    }
  }

  ParseResult? _processOpenAiResponse(http.Response response) {
    if (response.statusCode != 200) return null;
    try {
      final data = jsonDecode(response.body);
      final text = data['choices'][0]['message']['content'] as String;
      return _parseJsonResult(text);
    } catch (_) {
      return null;
    }
  }

  // ─── Gemini format ────────────────────────────────────────────────

  Future<ParseResult?> _callGeminiText(AiProviderConfig config, String blockText) async {
    try {
      final url = '${config.baseUrl}/models/${config.model}:generateContent?key=${config.apiKey}';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [{'text': _fullPrompt}],
          },
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': 'Parse this business card.\n\n$blockText'}],
            },
          ],
          'generationConfig': {
            'maxOutputTokens': 800,
            'temperature': 0.1,
          },
        }),
      ).timeout(_timeout);
      return _processGeminiResponse(response);
    } catch (_) {
      return null;
    }
  }

  Future<ParseResult?> _callGeminiVision(AiProviderConfig config, OcrResult ocrResult, String? imagePath) async {
    try {
      final parts = <Map<String, dynamic>>[];
      if (imagePath != null) {
        final imageBytes = await File(imagePath).readAsBytes();
        final base64Image = base64Encode(imageBytes);
        parts.add({
          'inlineData': {
            'mimeType': 'image/jpeg',
            'data': base64Image,
          },
        });
      }
      final blockText = _formatBlocks(ocrResult);
      parts.add({
        'text': 'Parse this business card. Use both the image AND the OCR text.\n\n$blockText\n\nAnalyze it and return your answer per the system instructions.',
      });

      final url = '${config.baseUrl}/models/${config.effectiveVisionModel}:generateContent?key=${config.apiKey}';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [{'text': _fullPrompt}],
          },
          'contents': [
            {'role': 'user', 'parts': parts},
          ],
          'generationConfig': {
            'maxOutputTokens': 1000,
            'temperature': 0.1,
          },
        }),
      ).timeout(_timeout);
      return _processGeminiResponse(response);
    } catch (_) {
      return null;
    }
  }

  ParseResult? _processGeminiResponse(http.Response response) {
    if (response.statusCode != 200) return null;
    try {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      return _parseJsonResult(text);
    } catch (_) {
      return null;
    }
  }

  // ─── Shared JSON parsing ──────────────────────────────────────────

  ParseResult? _parseJsonResult(String text) {
    try {
      final clean = text.replaceAll(RegExp(r'```json|```'), '').trim();
      final Map<String, dynamic> json = jsonDecode(clean);

      String? extractVal(dynamic field) {
        if (field is Map && field.containsKey('value')) return field['value'] as String?;
        if (field is String) return field;
        return null;
      }

      List<String> extractList(dynamic field) {
        if (field is List) {
          return field.map((e) {
            if (e is Map && e.containsKey('value')) return e['value'] as String;
            return e.toString();
          }).where((s) => s.isNotEmpty).toList();
        }
        return [];
      }

      String? safeString(dynamic field) {
        if (field is String) return field;
        if (field is Map && field.containsKey('value')) return field['value'] as String?;
        return null;
      }

      final confidenceMap = {
        'name': _extractNum(json['confidence'], 'name'),
        'company': _extractNum(json['confidence'], 'company'),
        'designation': _extractNum(json['confidence'], 'designation'),
        'phones': _extractNum(json['confidence'], 'phones'),
        'emails': _extractNum(json['confidence'], 'emails'),
        'website': _extractNum(json['confidence'], 'website'),
        'address': _extractNum(json['confidence'], 'address'),
      };

      String? linkedInUrl;
      String? twitterHandle;
      final social = json['social'];
      if (social is Map) {
        linkedInUrl = safeString(social['linkedin']);
        final other = social['other'];
        if (other is List) {
          for (final item in other) {
            final s = item.toString();
            if (s.toLowerCase().contains('twitter.com') || s.toLowerCase().contains('x.com')) {
              twitterHandle = s;
            }
          }
        }
      }

      return ParseResult(
        name: extractVal(json['name']),
        company: extractVal(json['company']),
        designation: extractVal(json['designation']),
        phones: extractList(json['phones']),
        emails: extractList(json['emails']),
        website: extractVal(json['website']),
        address: extractVal(json['address']),
        linkedInUrl: linkedInUrl,
        twitterHandle: twitterHandle,
        confidence: confidenceMap,
        parseMode: 'ai',
      );
    } catch (_) {
      return null;
    }
  }

  double _extractNum(dynamic conf, String field) {
    if (conf is Map) {
      final val = conf[field];
      if (val is num) return val.toDouble().clamp(0.0, 1.0);
    }
    return 0.0;
  }

  // ─── Test connection ──────────────────────────────────────────────

  Future<String?> testConnection(AiProviderConfig config) async {
    if (config.apiKey.isEmpty) return 'API key is empty';
    if (config.baseUrl.isEmpty) return 'Base URL is empty';
    if (config.model.isEmpty) return 'Model name is empty';

    try {
      final uri = config.format == ApiFormat.gemini
          ? Uri.parse('${config.baseUrl}/models/${config.model}:generateContent?key=${config.apiKey}')
          : Uri.parse('${config.baseUrl}/chat/completions');

      final headers = <String, String>{'Content-Type': 'application/json'};
      Map<String, dynamic> body;

      if (config.format == ApiFormat.gemini) {
        body = {
          'contents': [
            {'role': 'user', 'parts': [{'text': 'Say OK'}]},
          ],
          'generationConfig': {'maxOutputTokens': 10},
        };
      } else {
        headers['Authorization'] = 'Bearer ${config.apiKey}';
        body = {
          'model': config.model,
          'max_tokens': 10,
          'messages': [
            {'role': 'user', 'content': 'Say OK'},
          ],
        };
      }

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(_connectTimeout);

      if (response.statusCode == 200) return null;
      if (response.statusCode == 401) return 'Invalid API key';
      if (response.statusCode == 404) return 'Model not found: ${config.model}';
      return 'HTTP ${response.statusCode}';
    } catch (e) {
      return 'Connection failed: $e';
    }
  }
}
