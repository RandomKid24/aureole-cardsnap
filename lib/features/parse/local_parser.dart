import '../scan/ocr_service.dart';
import '../../core/models/parse_result.dart';

class LocalParser {
  static const List<String> designationKeywords = [
    'CEO', 'CTO', 'CFO', 'COO', 'MD', 'GM', 'Director', 'Manager', 'Engineer',
    'Developer', 'Designer', 'Consultant', 'Founder', 'Partner', 'President',
    'VP', 'Head', 'Lead', 'Senior', 'Junior', 'Executive', 'Officer', 'Analyst',
    'Specialist', 'Coordinator', 'Associate', 'Proprietor', 'Chairman', 'Secretary',
    'Treasurer', 'Principal', 'Professor', 'Doctor', 'Dr'
  ];

  static const List<String> addressSignals = [
    'Road', 'Street', 'Nagar', 'Colony', 'Plot', 'Flat', 'Floor', 'Building',
    'Tower', 'Sector', 'Phase', 'Industrial', 'Area', 'District', 'Pune', 'Mumbai',
    'Delhi', 'Bangalore', 'Chennai', 'Hyderabad', 'Nashik', 'Nagpur', 'Kolkata',
    'PIN', 'Maharashtra', 'India'
  ];

  ParseResult parse(List<OcrBlock> blocks) {
    String? name;
    String? company;
    String? designation;
    final List<String> phones = [];
    final List<String> emails = [];
    String? website;
    String? address;
    String? linkedInUrl;
    String? twitterHandle;
    final Map<String, double> confidence = {};

    final phoneRegex = RegExp(
      r'(\+?\d{1,3}[\s\-]?)?'      // optional country code
      r'(\(?\d{2,4}\)?[\s\-]?)?'   // optional area code
      r'\d{3,4}[\s\-]?\d{3,5}',    // subscriber number
    );
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}');
    final websiteRegex = RegExp(r'(https?://|www\.)[^\s]+', caseSensitive: false);
    final linkedInRegex = RegExp(r'linkedin\.com/in/[^\s]+', caseSensitive: false);
    final socialMediaRegex = RegExp(r'(?:https?:\/\/)?(?:www\.)?(?:linkedin\.com\/in\/|twitter\.com\/|facebook\.com\/|instagram\.com\/|x\.com\/)[A-Za-z0-9_\-\.]+', caseSensitive: false);

    final List<OcrBlock> anchorBlocks = [];

    for (final block in blocks) {
      bool isAnchor = false;
      final text = block.text;

      final emailMatch = emailRegex.firstMatch(text);
      if (emailMatch != null) {
        emails.add(emailMatch.group(0)!);
        confidence['emails'] = 0.95;
        isAnchor = true;
      }

      final phoneMatch = phoneRegex.firstMatch(text);
      if (phoneMatch != null) {
        phones.add(phoneMatch.group(0)!);
        confidence['phones'] = 0.95;
        isAnchor = true;
      }

      final linkedInMatch = linkedInRegex.firstMatch(text);
      if (linkedInMatch != null) {
        linkedInUrl = linkedInMatch.group(0)!;
        confidence['linkedInUrl'] = 0.95;
        isAnchor = true;
      }

      final socialMatch = socialMediaRegex.firstMatch(text);
      if (socialMatch != null) {
        twitterHandle = socialMatch.group(0)!;
        confidence['twitterHandle'] = 0.95;
        isAnchor = true;
      }

      final websiteMatch = websiteRegex.firstMatch(text);
      if (websiteMatch != null && linkedInMatch == null) {
        website = websiteMatch.group(0)!;
        confidence['website'] = 0.95;
        isAnchor = true;
      }

      if (isAnchor) anchorBlocks.add(block);
    }

    final nonAnchorBlocks = blocks.where((b) => !anchorBlocks.contains(b)).toList();

    if (nonAnchorBlocks.isNotEmpty) {
      // Sort by estimated font size
      final sorted = [...nonAnchorBlocks]..sort((a, b) => b.fontSize.compareTo(a.fontSize));
      
      for (final block in sorted) {
        final text = block.text.trim();
        // Skip if it looks like all-caps brand word or too long
        if (text == text.toUpperCase() && text.length > 2) continue;
        if (text.split(' ').length > 5) continue;
        
        name = text;
        confidence['name'] = 0.80;
        break;
      }

      if (sorted.length > 1) {
        final remaining = sorted.where((b) => b.text != name).toList();
        if (remaining.isNotEmpty) {
           company = remaining[0].text;
           confidence['company'] = 0.70;
        }
      }
    }

    for (final block in nonAnchorBlocks) {
      final textUpper = block.text.toUpperCase();
      
      if (designation == null) {
        for (final kw in designationKeywords) {
          if (textUpper.contains(kw.toUpperCase())) {
            designation = block.text;
            confidence['designation'] = 0.75;
            break;
          }
        }
      }

      if (address == null) {
        for (final signal in addressSignals) {
          if (textUpper.contains(signal.toUpperCase())) {
            address = block.text;
            confidence['address'] = 0.75;
            break;
          }
        }
      }
    }

    final List<String> flaggedFields = [];
    for (final field in ['name', 'company', 'designation', 'phones', 'emails', 'website', 'address', 'linkedInUrl', 'twitterHandle']) {
      final score = confidence[field] ?? 0.0;
      if (score < 0.65 && score > 0.0) flaggedFields.add(field);
    }

    return ParseResult(
      name: name,
      company: company,
      designation: designation,
      phones: phones,
      emails: emails,
      website: website,
      address: address,
      linkedInUrl: linkedInUrl,
      twitterHandle: twitterHandle,
      confidence: confidence,
      parseMode: 'local',
      flaggedFields: flaggedFields,
    );
  }
}
