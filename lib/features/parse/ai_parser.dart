import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  static const _systemPrompt = 'You are an expert at reading business cards. You will be given the OCR output from a business card — a list of text blocks with their approximate font size and position on the card — and optionally the card image itself.\n\nYour job is to figure out what each piece of text represents (name, company, job title, phone, email, address, website, social links) the way a person would if they picked up the card and read it. Use layout, font size, position, and context together — don\'t rely on any single signal alone.\n\nA few things worth keeping in mind (not rigid rules, just useful context):\n- The person\'s name is usually the most prominent text on the card, but not always — ALL CAPS text is not automatically a company. Check whether it has a company suffix (Ltd, LLP, Inc, Pvt Ltd, Technologies, etc.) before deciding it\'s a company.\n- A short phrase directly following or near the name, without a company suffix, is often a job title (CEO, Manager, Director, Founder, etc.), not part of the company name.\n- Address formats vary by country (4-6 digit postal codes, US ZIP+4, UK/Canada alphanumeric postcodes); state, region, and city names may appear without explicit labels. Keep phone numbers in the format printed on the card and preserve any leading + country code.\n- Company and name blocks are often positioned near each other, but company name can appear above OR below the person\'s name depending on card design — don\'t assume a fixed order.\n- A name can be genuinely absent (e.g. a generic company info card) — don\'t force a name onto a block that\'s actually a company or department name.\n\nThink through the card step by step first: describe briefly what you notice about layout and which block plausibly maps to which field, and why. Then output your final answer as JSON, strictly matching this schema:\n\n{\n  "name": string | null,\n  "company": string | null,\n  "designation": string | null,\n  "phones": string[],\n  "emails": string[],\n  "website": string | null,\n  "address": string | null,\n  "social": { "linkedin": string | null, "other": string[] },\n  "confidence": {\n    "name": number,\n    "company": number,\n    "designation": number,\n    "phones": number,\n    "emails": number,\n    "website": number,\n    "address": number\n  },\n  "reasoning": string\n}\n\nRules for confidence: if a field is genuinely ambiguous or you\'re guessing between two plausible options, give it a LOWER confidence score rather than picking one and reporting high confidence. A low-confidence honest answer is more useful than a wrong confident one — low-confidence fields get reviewed by a human before being saved.\n\nOnly output the JSON object as your final answer, after your reasoning. Do not include markdown code fences around the JSON.';

  static const _fewShotExamples = '\n\n---\n\nExample 1: Name at top, company below, no suffix (India)\n\nOCR blocks:\n  "VIVEK C. ZOPE" | fontSize: 18 | position: top-center\n  "Beforth" | fontSize: 13 | position: below block 1\n  "Software Development & Custom Solutions" | fontSize: 9 | position: below block 2\n  "vivek@beforth.in" | fontSize: 8 | position: bottom-left\n  "+91 98xxxxxxx" | fontSize: 8 | position: bottom-left\n\nReasoning: "VIVEK C. ZOPE" is ALL CAPS but has no company suffix and is at the top in the largest font — classic name placement. "Beforth" is smaller, right below the name, brand-like rather than a person\'s name. The line under it is a tagline, not a designation.\n\n{\n  "name": "VIVEK C. ZOPE",\n  "company": "Beforth",\n  "designation": null,\n  "phones": ["+9198xxxxxxx"],\n  "emails": ["vivek@beforth.in"],\n  "website": null,\n  "address": null,\n  "social": {"linkedin": null, "other": []},\n  "confidence": {"name": 0.9, "company": 0.7, "designation": 0.5, "phones": 0.9, "emails": 0.95, "website": 0.5, "address": 0.5},\n  "reasoning": "Name by top position and largest font. Company inferred from position and brand-like single word; no suffix so moderate confidence."\n}\n\n---\n\nExample 2: Company above name, US address\n\nOCR blocks:\n  "Northwind Traders, Inc." | fontSize: 16 | position: top-center\n  "Sarah Chen" | fontSize: 14 | position: below block 1\n  "VP, Business Development" | fontSize: 9 | position: below block 2\n  "sarah.chen@northwind.com" | fontSize: 8 | position: bottom-left\n  "+1 (415) 555-0142" | fontSize: 8 | position: bottom-left\n  "500 Market Street, Suite 400, San Francisco, CA 94105" | fontSize: 7 | position: bottom-center\n\nReasoning: "Northwind Traders, Inc." has an "Inc." suffix — the company. "Sarah Chen" is a personal name below it. "VP, Business Development" is a designation. The last line has a US street address with ZIP 94105.\n\n{\n  "name": "Sarah Chen",\n  "company": "Northwind Traders, Inc.",\n  "designation": "VP, Business Development",\n  "phones": ["+14155550142"],\n  "emails": ["sarah.chen@northwind.com"],\n  "website": null,\n  "address": "500 Market Street, Suite 400, San Francisco, CA 94105",\n  "social": {"linkedin": null, "other": []},\n  "confidence": {"name": 0.92, "company": 0.95, "designation": 0.88, "phones": 0.95, "emails": 0.95, "website": 0.5, "address": 0.9},\n  "reasoning": "Company has \'Inc.\' suffix. Name is title-case below company. Designation follows. Address has US street + state + ZIP."\n}\n\n---\n\nExample 3: Designation between name and company, European address, two phones\n\nOCR blocks:\n  "Dr. Lena Vogel" | fontSize: 15 | position: top-left\n  "Head of Research" | fontSize: 10 | position: below block 1\n  "Helvetica Labs GmbH" | fontSize: 11 | position: below block 2\n  "lena.vogel@helvetica-labs.de" | fontSize: 8 | position: bottom-left\n  "Tel +49 30 123456   Mob +49 170 9876543" | fontSize: 8 | position: bottom-left\n  "Torstrasse 12, 10119 Berlin, Germany" | fontSize: 6 | position: bottom-center\n\nReasoning: "Dr. Lena Vogel" is a personal name. "Head of Research" is a designation. "Helvetica Labs GmbH" has a "GmbH" suffix — the company. Two phone numbers on one line (landline + mobile). Address has a German street ("strasse") and 5-digit postal code.\n\n{\n  "name": "Dr. Lena Vogel",\n  "company": "Helvetica Labs GmbH",\n  "designation": "Head of Research",\n  "phones": ["+4930123456", "+491709876543"],\n  "emails": ["lena.vogel@helvetica-labs.de"],\n  "website": null,\n  "address": "Torstrasse 12, 10119 Berlin, Germany",\n  "social": {"linkedin": null, "other": []},\n  "confidence": {"name": 0.93, "company": 0.95, "designation": 0.9, "phones": 0.9, "emails": 0.95, "website": 0.5, "address": 0.9},\n  "reasoning": "Name title-case with title prefix. Designation is a role phrase, no suffix. Company has \'GmbH\'. Both numbers captured. Address has street + postal code + country."\n}';

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

  /// Whether AI parsing is switched on and has a usable key/model.
  Future<bool> isUsable() async {
    final c = await _keyStorage.getAiConfig();
    _lastConfig = c;
    return c.enabled && c.isUsable;
  }

  /// Set after [parse] runs: null on success, else why the AI result was dropped.
  String? lastError;

  Future<ParseResult?> parse(OcrResult ocrResult, String? imagePath, double confidence) async {
    lastError = null;
    final key = ocrResult.rawText.hashCode.toString();
    if (_cache.containsKey(key)) return _cache[key];

    final config = await _keyStorage.getAiConfig();
    _lastConfig = config;

    if (!config.enabled) {
      lastError = 'AI parsing is off';
      return null;
    }
    if (!config.isUsable) {
      lastError = 'AI is enabled but the key/model is incomplete';
      return null;
    }

    // One multimodal request: the card image (when available) plus the OCR
    // blocks go in together. No text/vision tiering.
    final result = config.isGemini
        ? await _callGemini(config, ocrResult, imagePath)
        : await _callOpenAi(config, ocrResult, imagePath);

    if (result != null) {
      _cache[key] = result;
    } else {
      lastError ??= 'AI request failed (network, model, or bad response)';
    }
    return result;
  }

  // ─── OpenAI-compatible format ─────────────────────────────────────

  Future<ParseResult?> _callOpenAi(
      AiProviderConfig config, OcrResult ocrResult, String? imagePath) async {
    try {
      final contentParts = <Map<String, dynamic>>[];
      if (imagePath != null) {
        final base64Image = base64Encode(await File(imagePath).readAsBytes());
        contentParts.add({
          'type': 'image_url',
          'image_url': {'url': 'data:image/jpeg;base64,$base64Image', 'detail': 'high'},
        });
      }
      contentParts.add({
        'type': 'text',
        'text': 'Parse this business card. Use the image AND the OCR text.\n\n'
            '${_formatBlocks(ocrResult)}\n\nReturn your answer per the system instructions.',
      });

      // Groq retires models regularly: if the chosen one is gone, fall through
      // to the next known vision model instead of failing the scan.
      final models = <String>{
        config.effectiveModel,
        if (config.type == AiProviderType.groq) ...AiProviderConfig.groqFallbackModels,
      }.toList();
      http.Response response;
      var i = 0;
      while (true) {
        response = await http.post(
          Uri.parse('${config.baseUrl}/chat/completions'),
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': models[i],
            'max_tokens': 1000,
            'messages': [
              {'role': 'system', 'content': _fullPrompt},
              {'role': 'user', 'content': contentParts},
            ],
          }),
        ).timeout(_timeout);
        final modelGone = response.statusCode == 404 ||
            (response.statusCode == 400 && response.body.contains('model'));
        if (modelGone && i + 1 < models.length) {
          i++;
          continue;
        }
        break;
      }
      return _processOpenAiResponse(response);
    } catch (e) {
      lastError = 'Request failed: $e';
      debugPrint('AiParser: OpenAI call failed: $e');
      return null;
    }
  }

  ParseResult? _processOpenAiResponse(http.Response response) {
    if (response.statusCode != 200) {
      lastError = _httpError(response);
      return null;
    }
    try {
      final data = jsonDecode(response.body);
      final text = data['choices'][0]['message']['content'] as String;
      final r = _parseJsonResult(text);
      if (r == null) lastError = 'AI returned a response that could not be parsed';
      return r;
    } catch (_) {
      lastError = 'Unexpected response shape from the provider';
      return null;
    }
  }

  String _httpError(http.Response r) {
    switch (r.statusCode) {
      case 401:
      case 403:
        return 'Invalid API key';
      case 404:
        return 'Model "${_lastConfig?.effectiveModel}" not found for this provider';
      case 429:
        return 'Rate limited / quota exceeded';
      default:
        return 'Provider returned HTTP ${r.statusCode}';
    }
  }

  // ─── Gemini format ────────────────────────────────────────────────

  Future<ParseResult?> _callGemini(
      AiProviderConfig config, OcrResult ocrResult, String? imagePath) async {
    try {
      final parts = <Map<String, dynamic>>[];
      if (imagePath != null) {
        final base64Image = base64Encode(await File(imagePath).readAsBytes());
        parts.add({
          'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image},
        });
      }
      parts.add({
        'text': 'Parse this business card. Use the image AND the OCR text.\n\n'
            '${_formatBlocks(ocrResult)}\n\nReturn your answer per the system instructions.',
      });

      final url =
          '${config.baseUrl}/models/${config.effectiveModel}:generateContent?key=${config.apiKey}';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [
              {'text': _fullPrompt}
            ],
          },
          'contents': [
            {'role': 'user', 'parts': parts},
          ],
          'generationConfig': {'maxOutputTokens': 1000, 'temperature': 0.1},
        }),
      ).timeout(_timeout);
      return _processGeminiResponse(response);
    } catch (e) {
      lastError = 'Request failed: $e';
      debugPrint('AiParser: Gemini call failed: $e');
      return null;
    }
  }

  ParseResult? _processGeminiResponse(http.Response response) {
    if (response.statusCode != 200) {
      lastError = _httpError(response);
      return null;
    }
    try {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      final r = _parseJsonResult(text);
      if (r == null) lastError = 'AI returned a response that could not be parsed';
      return r;
    } catch (_) {
      lastError = 'Unexpected response shape from the provider';
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
    if (config.apiKey.trim().isEmpty) return 'Enter an API key first';
    if (config.type == AiProviderType.custom) {
      final uri = Uri.tryParse(config.customBaseUrl.trim());
      if (uri == null || !uri.isAbsolute || uri.scheme != 'https') {
        return 'Custom base URL must be a valid https:// URL';
      }
    }
    final model = config.effectiveModel;
    if (model.isEmpty) return 'Enter a model name';

    try {
      final Uri uri;
      final headers = <String, String>{'Content-Type': 'application/json'};
      final Map<String, dynamic> body;

      if (config.isGemini) {
        uri = Uri.parse(
            '${config.baseUrl}/models/$model:generateContent?key=${config.apiKey}');
        body = {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': 'Say OK'}
              ]
            },
          ],
          'generationConfig': {'maxOutputTokens': 10},
        };
      } else {
        uri = Uri.parse('${config.baseUrl}/chat/completions');
        headers['Authorization'] = 'Bearer ${config.apiKey}';
        body = {
          'model': model,
          'max_tokens': 10,
          'messages': [
            {'role': 'user', 'content': 'Say OK'},
          ],
        };
      }

      final response =
          await http.post(uri, headers: headers, body: jsonEncode(body)).timeout(_connectTimeout);

      if (response.statusCode == 200) return null;
      if (response.statusCode == 401 || response.statusCode == 403) return 'Invalid API key';
      if (response.statusCode == 404) return 'Model "$model" not found for this provider';
      return 'HTTP ${response.statusCode}';
    } catch (e) {
      return 'Connection failed: $e';
    }
  }
}
