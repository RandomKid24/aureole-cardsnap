// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _companyMeta =
      const VerificationMeta('company');
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
      'company', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _designationMeta =
      const VerificationMeta('designation');
  @override
  late final GeneratedColumn<String> designation = GeneratedColumn<String>(
      'designation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phonesJsonMeta =
      const VerificationMeta('phonesJson');
  @override
  late final GeneratedColumn<String> phonesJson = GeneratedColumn<String>(
      'phones_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailsJsonMeta =
      const VerificationMeta('emailsJson');
  @override
  late final GeneratedColumn<String> emailsJson = GeneratedColumn<String>(
      'emails_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _websiteMeta =
      const VerificationMeta('website');
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
      'website', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageFrontPathMeta =
      const VerificationMeta('imageFrontPath');
  @override
  late final GeneratedColumn<String> imageFrontPath = GeneratedColumn<String>(
      'image_front_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageBackPathMeta =
      const VerificationMeta('imageBackPath');
  @override
  late final GeneratedColumn<String> imageBackPath = GeneratedColumn<String>(
      'image_back_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceJsonMeta =
      const VerificationMeta('confidenceJson');
  @override
  late final GeneratedColumn<String> confidenceJson = GeneratedColumn<String>(
      'confidence_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parseModeMeta =
      const VerificationMeta('parseMode');
  @override
  late final GeneratedColumn<String> parseMode = GeneratedColumn<String>(
      'parse_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastContactedAtMeta =
      const VerificationMeta('lastContactedAt');
  @override
  late final GeneratedColumn<DateTime> lastContactedAt =
      GeneratedColumn<DateTime>('last_contacted_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _reminderNoteMeta =
      const VerificationMeta('reminderNote');
  @override
  late final GeneratedColumn<String> reminderNote = GeneratedColumn<String>(
      'reminder_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reminderDateMeta =
      const VerificationMeta('reminderDate');
  @override
  late final GeneratedColumn<DateTime> reminderDate = GeneratedColumn<DateTime>(
      'reminder_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _reminderDoneMeta =
      const VerificationMeta('reminderDone');
  @override
  late final GeneratedColumn<bool> reminderDone = GeneratedColumn<bool>(
      'reminder_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reminder_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _scanCountMeta =
      const VerificationMeta('scanCount');
  @override
  late final GeneratedColumn<int> scanCount = GeneratedColumn<int>(
      'scan_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _linkedInUrlMeta =
      const VerificationMeta('linkedInUrl');
  @override
  late final GeneratedColumn<String> linkedInUrl = GeneratedColumn<String>(
      'linked_in_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _twitterHandleMeta =
      const VerificationMeta('twitterHandle');
  @override
  late final GeneratedColumn<String> twitterHandle = GeneratedColumn<String>(
      'twitter_handle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiModelUsedMeta =
      const VerificationMeta('aiModelUsed');
  @override
  late final GeneratedColumn<String> aiModelUsed = GeneratedColumn<String>(
      'ai_model_used', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _processingDurationMsMeta =
      const VerificationMeta('processingDurationMs');
  @override
  late final GeneratedColumn<int> processingDurationMs = GeneratedColumn<int>(
      'processing_duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ocrDurationMsMeta =
      const VerificationMeta('ocrDurationMs');
  @override
  late final GeneratedColumn<int> ocrDurationMs = GeneratedColumn<int>(
      'ocr_duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _parserDurationMsMeta =
      const VerificationMeta('parserDurationMs');
  @override
  late final GeneratedColumn<int> parserDurationMs = GeneratedColumn<int>(
      'parser_duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _imageQualityScoreMeta =
      const VerificationMeta('imageQualityScore');
  @override
  late final GeneratedColumn<double> imageQualityScore =
      GeneratedColumn<double>('image_quality_score', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _parserSourceMeta =
      const VerificationMeta('parserSource');
  @override
  late final GeneratedColumn<String> parserSource = GeneratedColumn<String>(
      'parser_source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _parserVersionMeta =
      const VerificationMeta('parserVersion');
  @override
  late final GeneratedColumn<int> parserVersion = GeneratedColumn<int>(
      'parser_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        company,
        designation,
        phonesJson,
        emailsJson,
        website,
        address,
        imageFrontPath,
        imageBackPath,
        confidenceJson,
        parseMode,
        createdAt,
        updatedAt,
        lastContactedAt,
        isFavorite,
        tagsJson,
        reminderNote,
        reminderDate,
        reminderDone,
        scanCount,
        linkedInUrl,
        twitterHandle,
        aiModelUsed,
        processingDurationMs,
        ocrDurationMs,
        parserDurationMs,
        imageQualityScore,
        parserSource,
        parserVersion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<Contact> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('company')) {
      context.handle(_companyMeta,
          company.isAcceptableOrUnknown(data['company']!, _companyMeta));
    }
    if (data.containsKey('designation')) {
      context.handle(
          _designationMeta,
          designation.isAcceptableOrUnknown(
              data['designation']!, _designationMeta));
    }
    if (data.containsKey('phones_json')) {
      context.handle(
          _phonesJsonMeta,
          phonesJson.isAcceptableOrUnknown(
              data['phones_json']!, _phonesJsonMeta));
    } else if (isInserting) {
      context.missing(_phonesJsonMeta);
    }
    if (data.containsKey('emails_json')) {
      context.handle(
          _emailsJsonMeta,
          emailsJson.isAcceptableOrUnknown(
              data['emails_json']!, _emailsJsonMeta));
    } else if (isInserting) {
      context.missing(_emailsJsonMeta);
    }
    if (data.containsKey('website')) {
      context.handle(_websiteMeta,
          website.isAcceptableOrUnknown(data['website']!, _websiteMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('image_front_path')) {
      context.handle(
          _imageFrontPathMeta,
          imageFrontPath.isAcceptableOrUnknown(
              data['image_front_path']!, _imageFrontPathMeta));
    }
    if (data.containsKey('image_back_path')) {
      context.handle(
          _imageBackPathMeta,
          imageBackPath.isAcceptableOrUnknown(
              data['image_back_path']!, _imageBackPathMeta));
    }
    if (data.containsKey('confidence_json')) {
      context.handle(
          _confidenceJsonMeta,
          confidenceJson.isAcceptableOrUnknown(
              data['confidence_json']!, _confidenceJsonMeta));
    } else if (isInserting) {
      context.missing(_confidenceJsonMeta);
    }
    if (data.containsKey('parse_mode')) {
      context.handle(_parseModeMeta,
          parseMode.isAcceptableOrUnknown(data['parse_mode']!, _parseModeMeta));
    } else if (isInserting) {
      context.missing(_parseModeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('last_contacted_at')) {
      context.handle(
          _lastContactedAtMeta,
          lastContactedAt.isAcceptableOrUnknown(
              data['last_contacted_at']!, _lastContactedAtMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('reminder_note')) {
      context.handle(
          _reminderNoteMeta,
          reminderNote.isAcceptableOrUnknown(
              data['reminder_note']!, _reminderNoteMeta));
    }
    if (data.containsKey('reminder_date')) {
      context.handle(
          _reminderDateMeta,
          reminderDate.isAcceptableOrUnknown(
              data['reminder_date']!, _reminderDateMeta));
    }
    if (data.containsKey('reminder_done')) {
      context.handle(
          _reminderDoneMeta,
          reminderDone.isAcceptableOrUnknown(
              data['reminder_done']!, _reminderDoneMeta));
    }
    if (data.containsKey('scan_count')) {
      context.handle(_scanCountMeta,
          scanCount.isAcceptableOrUnknown(data['scan_count']!, _scanCountMeta));
    }
    if (data.containsKey('linked_in_url')) {
      context.handle(
          _linkedInUrlMeta,
          linkedInUrl.isAcceptableOrUnknown(
              data['linked_in_url']!, _linkedInUrlMeta));
    }
    if (data.containsKey('twitter_handle')) {
      context.handle(
          _twitterHandleMeta,
          twitterHandle.isAcceptableOrUnknown(
              data['twitter_handle']!, _twitterHandleMeta));
    }
    if (data.containsKey('ai_model_used')) {
      context.handle(
          _aiModelUsedMeta,
          aiModelUsed.isAcceptableOrUnknown(
              data['ai_model_used']!, _aiModelUsedMeta));
    }
    if (data.containsKey('processing_duration_ms')) {
      context.handle(
          _processingDurationMsMeta,
          processingDurationMs.isAcceptableOrUnknown(
              data['processing_duration_ms']!, _processingDurationMsMeta));
    }
    if (data.containsKey('ocr_duration_ms')) {
      context.handle(
          _ocrDurationMsMeta,
          ocrDurationMs.isAcceptableOrUnknown(
              data['ocr_duration_ms']!, _ocrDurationMsMeta));
    }
    if (data.containsKey('parser_duration_ms')) {
      context.handle(
          _parserDurationMsMeta,
          parserDurationMs.isAcceptableOrUnknown(
              data['parser_duration_ms']!, _parserDurationMsMeta));
    }
    if (data.containsKey('image_quality_score')) {
      context.handle(
          _imageQualityScoreMeta,
          imageQualityScore.isAcceptableOrUnknown(
              data['image_quality_score']!, _imageQualityScoreMeta));
    }
    if (data.containsKey('parser_source')) {
      context.handle(
          _parserSourceMeta,
          parserSource.isAcceptableOrUnknown(
              data['parser_source']!, _parserSourceMeta));
    }
    if (data.containsKey('parser_version')) {
      context.handle(
          _parserVersionMeta,
          parserVersion.isAcceptableOrUnknown(
              data['parser_version']!, _parserVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      company: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company']),
      designation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}designation']),
      phonesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phones_json'])!,
      emailsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emails_json'])!,
      website: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      imageFrontPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}image_front_path']),
      imageBackPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_back_path']),
      confidenceJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}confidence_json'])!,
      parseMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parse_mode'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      lastContactedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_contacted_at']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      reminderNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reminder_note']),
      reminderDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reminder_date']),
      reminderDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}reminder_done'])!,
      scanCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scan_count'])!,
      linkedInUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linked_in_url']),
      twitterHandle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}twitter_handle']),
      aiModelUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_model_used']),
      processingDurationMs: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}processing_duration_ms']),
      ocrDurationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ocr_duration_ms']),
      parserDurationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parser_duration_ms']),
      imageQualityScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}image_quality_score']),
      parserSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parser_source'])!,
      parserVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parser_version'])!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final String id;
  final String name;
  final String? company;
  final String? designation;
  final String phonesJson;
  final String emailsJson;
  final String? website;
  final String? address;
  final String? imageFrontPath;
  final String? imageBackPath;
  final String confidenceJson;
  final String parseMode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastContactedAt;
  final bool isFavorite;
  final String tagsJson;
  final String? reminderNote;
  final DateTime? reminderDate;
  final bool reminderDone;
  final int scanCount;
  final String? linkedInUrl;
  final String? twitterHandle;
  final String? aiModelUsed;
  final int? processingDurationMs;
  final int? ocrDurationMs;
  final int? parserDurationMs;
  final double? imageQualityScore;
  final String parserSource;
  final int parserVersion;
  const Contact(
      {required this.id,
      required this.name,
      this.company,
      this.designation,
      required this.phonesJson,
      required this.emailsJson,
      this.website,
      this.address,
      this.imageFrontPath,
      this.imageBackPath,
      required this.confidenceJson,
      required this.parseMode,
      required this.createdAt,
      this.updatedAt,
      this.lastContactedAt,
      required this.isFavorite,
      required this.tagsJson,
      this.reminderNote,
      this.reminderDate,
      required this.reminderDone,
      required this.scanCount,
      this.linkedInUrl,
      this.twitterHandle,
      this.aiModelUsed,
      this.processingDurationMs,
      this.ocrDurationMs,
      this.parserDurationMs,
      this.imageQualityScore,
      required this.parserSource,
      required this.parserVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || designation != null) {
      map['designation'] = Variable<String>(designation);
    }
    map['phones_json'] = Variable<String>(phonesJson);
    map['emails_json'] = Variable<String>(emailsJson);
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || imageFrontPath != null) {
      map['image_front_path'] = Variable<String>(imageFrontPath);
    }
    if (!nullToAbsent || imageBackPath != null) {
      map['image_back_path'] = Variable<String>(imageBackPath);
    }
    map['confidence_json'] = Variable<String>(confidenceJson);
    map['parse_mode'] = Variable<String>(parseMode);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || lastContactedAt != null) {
      map['last_contacted_at'] = Variable<DateTime>(lastContactedAt);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['tags_json'] = Variable<String>(tagsJson);
    if (!nullToAbsent || reminderNote != null) {
      map['reminder_note'] = Variable<String>(reminderNote);
    }
    if (!nullToAbsent || reminderDate != null) {
      map['reminder_date'] = Variable<DateTime>(reminderDate);
    }
    map['reminder_done'] = Variable<bool>(reminderDone);
    map['scan_count'] = Variable<int>(scanCount);
    if (!nullToAbsent || linkedInUrl != null) {
      map['linked_in_url'] = Variable<String>(linkedInUrl);
    }
    if (!nullToAbsent || twitterHandle != null) {
      map['twitter_handle'] = Variable<String>(twitterHandle);
    }
    if (!nullToAbsent || aiModelUsed != null) {
      map['ai_model_used'] = Variable<String>(aiModelUsed);
    }
    if (!nullToAbsent || processingDurationMs != null) {
      map['processing_duration_ms'] = Variable<int>(processingDurationMs);
    }
    if (!nullToAbsent || ocrDurationMs != null) {
      map['ocr_duration_ms'] = Variable<int>(ocrDurationMs);
    }
    if (!nullToAbsent || parserDurationMs != null) {
      map['parser_duration_ms'] = Variable<int>(parserDurationMs);
    }
    if (!nullToAbsent || imageQualityScore != null) {
      map['image_quality_score'] = Variable<double>(imageQualityScore);
    }
    map['parser_source'] = Variable<String>(parserSource);
    map['parser_version'] = Variable<int>(parserVersion);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      name: Value(name),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      designation: designation == null && nullToAbsent
          ? const Value.absent()
          : Value(designation),
      phonesJson: Value(phonesJson),
      emailsJson: Value(emailsJson),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      imageFrontPath: imageFrontPath == null && nullToAbsent
          ? const Value.absent()
          : Value(imageFrontPath),
      imageBackPath: imageBackPath == null && nullToAbsent
          ? const Value.absent()
          : Value(imageBackPath),
      confidenceJson: Value(confidenceJson),
      parseMode: Value(parseMode),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      lastContactedAt: lastContactedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastContactedAt),
      isFavorite: Value(isFavorite),
      tagsJson: Value(tagsJson),
      reminderNote: reminderNote == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderNote),
      reminderDate: reminderDate == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderDate),
      reminderDone: Value(reminderDone),
      scanCount: Value(scanCount),
      linkedInUrl: linkedInUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedInUrl),
      twitterHandle: twitterHandle == null && nullToAbsent
          ? const Value.absent()
          : Value(twitterHandle),
      aiModelUsed: aiModelUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(aiModelUsed),
      processingDurationMs: processingDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(processingDurationMs),
      ocrDurationMs: ocrDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrDurationMs),
      parserDurationMs: parserDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(parserDurationMs),
      imageQualityScore: imageQualityScore == null && nullToAbsent
          ? const Value.absent()
          : Value(imageQualityScore),
      parserSource: Value(parserSource),
      parserVersion: Value(parserVersion),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      company: serializer.fromJson<String?>(json['company']),
      designation: serializer.fromJson<String?>(json['designation']),
      phonesJson: serializer.fromJson<String>(json['phonesJson']),
      emailsJson: serializer.fromJson<String>(json['emailsJson']),
      website: serializer.fromJson<String?>(json['website']),
      address: serializer.fromJson<String?>(json['address']),
      imageFrontPath: serializer.fromJson<String?>(json['imageFrontPath']),
      imageBackPath: serializer.fromJson<String?>(json['imageBackPath']),
      confidenceJson: serializer.fromJson<String>(json['confidenceJson']),
      parseMode: serializer.fromJson<String>(json['parseMode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      lastContactedAt: serializer.fromJson<DateTime?>(json['lastContactedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      reminderNote: serializer.fromJson<String?>(json['reminderNote']),
      reminderDate: serializer.fromJson<DateTime?>(json['reminderDate']),
      reminderDone: serializer.fromJson<bool>(json['reminderDone']),
      scanCount: serializer.fromJson<int>(json['scanCount']),
      linkedInUrl: serializer.fromJson<String?>(json['linkedInUrl']),
      twitterHandle: serializer.fromJson<String?>(json['twitterHandle']),
      aiModelUsed: serializer.fromJson<String?>(json['aiModelUsed']),
      processingDurationMs:
          serializer.fromJson<int?>(json['processingDurationMs']),
      ocrDurationMs: serializer.fromJson<int?>(json['ocrDurationMs']),
      parserDurationMs: serializer.fromJson<int?>(json['parserDurationMs']),
      imageQualityScore:
          serializer.fromJson<double?>(json['imageQualityScore']),
      parserSource: serializer.fromJson<String>(json['parserSource']),
      parserVersion: serializer.fromJson<int>(json['parserVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'company': serializer.toJson<String?>(company),
      'designation': serializer.toJson<String?>(designation),
      'phonesJson': serializer.toJson<String>(phonesJson),
      'emailsJson': serializer.toJson<String>(emailsJson),
      'website': serializer.toJson<String?>(website),
      'address': serializer.toJson<String?>(address),
      'imageFrontPath': serializer.toJson<String?>(imageFrontPath),
      'imageBackPath': serializer.toJson<String?>(imageBackPath),
      'confidenceJson': serializer.toJson<String>(confidenceJson),
      'parseMode': serializer.toJson<String>(parseMode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'lastContactedAt': serializer.toJson<DateTime?>(lastContactedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'reminderNote': serializer.toJson<String?>(reminderNote),
      'reminderDate': serializer.toJson<DateTime?>(reminderDate),
      'reminderDone': serializer.toJson<bool>(reminderDone),
      'scanCount': serializer.toJson<int>(scanCount),
      'linkedInUrl': serializer.toJson<String?>(linkedInUrl),
      'twitterHandle': serializer.toJson<String?>(twitterHandle),
      'aiModelUsed': serializer.toJson<String?>(aiModelUsed),
      'processingDurationMs': serializer.toJson<int?>(processingDurationMs),
      'ocrDurationMs': serializer.toJson<int?>(ocrDurationMs),
      'parserDurationMs': serializer.toJson<int?>(parserDurationMs),
      'imageQualityScore': serializer.toJson<double?>(imageQualityScore),
      'parserSource': serializer.toJson<String>(parserSource),
      'parserVersion': serializer.toJson<int>(parserVersion),
    };
  }

  Contact copyWith(
          {String? id,
          String? name,
          Value<String?> company = const Value.absent(),
          Value<String?> designation = const Value.absent(),
          String? phonesJson,
          String? emailsJson,
          Value<String?> website = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> imageFrontPath = const Value.absent(),
          Value<String?> imageBackPath = const Value.absent(),
          String? confidenceJson,
          String? parseMode,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> lastContactedAt = const Value.absent(),
          bool? isFavorite,
          String? tagsJson,
          Value<String?> reminderNote = const Value.absent(),
          Value<DateTime?> reminderDate = const Value.absent(),
          bool? reminderDone,
          int? scanCount,
          Value<String?> linkedInUrl = const Value.absent(),
          Value<String?> twitterHandle = const Value.absent(),
          Value<String?> aiModelUsed = const Value.absent(),
          Value<int?> processingDurationMs = const Value.absent(),
          Value<int?> ocrDurationMs = const Value.absent(),
          Value<int?> parserDurationMs = const Value.absent(),
          Value<double?> imageQualityScore = const Value.absent(),
          String? parserSource,
          int? parserVersion}) =>
      Contact(
        id: id ?? this.id,
        name: name ?? this.name,
        company: company.present ? company.value : this.company,
        designation: designation.present ? designation.value : this.designation,
        phonesJson: phonesJson ?? this.phonesJson,
        emailsJson: emailsJson ?? this.emailsJson,
        website: website.present ? website.value : this.website,
        address: address.present ? address.value : this.address,
        imageFrontPath:
            imageFrontPath.present ? imageFrontPath.value : this.imageFrontPath,
        imageBackPath:
            imageBackPath.present ? imageBackPath.value : this.imageBackPath,
        confidenceJson: confidenceJson ?? this.confidenceJson,
        parseMode: parseMode ?? this.parseMode,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        lastContactedAt: lastContactedAt.present
            ? lastContactedAt.value
            : this.lastContactedAt,
        isFavorite: isFavorite ?? this.isFavorite,
        tagsJson: tagsJson ?? this.tagsJson,
        reminderNote:
            reminderNote.present ? reminderNote.value : this.reminderNote,
        reminderDate:
            reminderDate.present ? reminderDate.value : this.reminderDate,
        reminderDone: reminderDone ?? this.reminderDone,
        scanCount: scanCount ?? this.scanCount,
        linkedInUrl: linkedInUrl.present ? linkedInUrl.value : this.linkedInUrl,
        twitterHandle:
            twitterHandle.present ? twitterHandle.value : this.twitterHandle,
        aiModelUsed: aiModelUsed.present ? aiModelUsed.value : this.aiModelUsed,
        processingDurationMs: processingDurationMs.present
            ? processingDurationMs.value
            : this.processingDurationMs,
        ocrDurationMs:
            ocrDurationMs.present ? ocrDurationMs.value : this.ocrDurationMs,
        parserDurationMs: parserDurationMs.present
            ? parserDurationMs.value
            : this.parserDurationMs,
        imageQualityScore: imageQualityScore.present
            ? imageQualityScore.value
            : this.imageQualityScore,
        parserSource: parserSource ?? this.parserSource,
        parserVersion: parserVersion ?? this.parserVersion,
      );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      company: data.company.present ? data.company.value : this.company,
      designation:
          data.designation.present ? data.designation.value : this.designation,
      phonesJson:
          data.phonesJson.present ? data.phonesJson.value : this.phonesJson,
      emailsJson:
          data.emailsJson.present ? data.emailsJson.value : this.emailsJson,
      website: data.website.present ? data.website.value : this.website,
      address: data.address.present ? data.address.value : this.address,
      imageFrontPath: data.imageFrontPath.present
          ? data.imageFrontPath.value
          : this.imageFrontPath,
      imageBackPath: data.imageBackPath.present
          ? data.imageBackPath.value
          : this.imageBackPath,
      confidenceJson: data.confidenceJson.present
          ? data.confidenceJson.value
          : this.confidenceJson,
      parseMode: data.parseMode.present ? data.parseMode.value : this.parseMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastContactedAt: data.lastContactedAt.present
          ? data.lastContactedAt.value
          : this.lastContactedAt,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      reminderNote: data.reminderNote.present
          ? data.reminderNote.value
          : this.reminderNote,
      reminderDate: data.reminderDate.present
          ? data.reminderDate.value
          : this.reminderDate,
      reminderDone: data.reminderDone.present
          ? data.reminderDone.value
          : this.reminderDone,
      scanCount: data.scanCount.present ? data.scanCount.value : this.scanCount,
      linkedInUrl:
          data.linkedInUrl.present ? data.linkedInUrl.value : this.linkedInUrl,
      twitterHandle: data.twitterHandle.present
          ? data.twitterHandle.value
          : this.twitterHandle,
      aiModelUsed:
          data.aiModelUsed.present ? data.aiModelUsed.value : this.aiModelUsed,
      processingDurationMs: data.processingDurationMs.present
          ? data.processingDurationMs.value
          : this.processingDurationMs,
      ocrDurationMs: data.ocrDurationMs.present
          ? data.ocrDurationMs.value
          : this.ocrDurationMs,
      parserDurationMs: data.parserDurationMs.present
          ? data.parserDurationMs.value
          : this.parserDurationMs,
      imageQualityScore: data.imageQualityScore.present
          ? data.imageQualityScore.value
          : this.imageQualityScore,
      parserSource: data.parserSource.present
          ? data.parserSource.value
          : this.parserSource,
      parserVersion: data.parserVersion.present
          ? data.parserVersion.value
          : this.parserVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('designation: $designation, ')
          ..write('phonesJson: $phonesJson, ')
          ..write('emailsJson: $emailsJson, ')
          ..write('website: $website, ')
          ..write('address: $address, ')
          ..write('imageFrontPath: $imageFrontPath, ')
          ..write('imageBackPath: $imageBackPath, ')
          ..write('confidenceJson: $confidenceJson, ')
          ..write('parseMode: $parseMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastContactedAt: $lastContactedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('reminderNote: $reminderNote, ')
          ..write('reminderDate: $reminderDate, ')
          ..write('reminderDone: $reminderDone, ')
          ..write('scanCount: $scanCount, ')
          ..write('linkedInUrl: $linkedInUrl, ')
          ..write('twitterHandle: $twitterHandle, ')
          ..write('aiModelUsed: $aiModelUsed, ')
          ..write('processingDurationMs: $processingDurationMs, ')
          ..write('ocrDurationMs: $ocrDurationMs, ')
          ..write('parserDurationMs: $parserDurationMs, ')
          ..write('imageQualityScore: $imageQualityScore, ')
          ..write('parserSource: $parserSource, ')
          ..write('parserVersion: $parserVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        company,
        designation,
        phonesJson,
        emailsJson,
        website,
        address,
        imageFrontPath,
        imageBackPath,
        confidenceJson,
        parseMode,
        createdAt,
        updatedAt,
        lastContactedAt,
        isFavorite,
        tagsJson,
        reminderNote,
        reminderDate,
        reminderDone,
        scanCount,
        linkedInUrl,
        twitterHandle,
        aiModelUsed,
        processingDurationMs,
        ocrDurationMs,
        parserDurationMs,
        imageQualityScore,
        parserSource,
        parserVersion
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.name == this.name &&
          other.company == this.company &&
          other.designation == this.designation &&
          other.phonesJson == this.phonesJson &&
          other.emailsJson == this.emailsJson &&
          other.website == this.website &&
          other.address == this.address &&
          other.imageFrontPath == this.imageFrontPath &&
          other.imageBackPath == this.imageBackPath &&
          other.confidenceJson == this.confidenceJson &&
          other.parseMode == this.parseMode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastContactedAt == this.lastContactedAt &&
          other.isFavorite == this.isFavorite &&
          other.tagsJson == this.tagsJson &&
          other.reminderNote == this.reminderNote &&
          other.reminderDate == this.reminderDate &&
          other.reminderDone == this.reminderDone &&
          other.scanCount == this.scanCount &&
          other.linkedInUrl == this.linkedInUrl &&
          other.twitterHandle == this.twitterHandle &&
          other.aiModelUsed == this.aiModelUsed &&
          other.processingDurationMs == this.processingDurationMs &&
          other.ocrDurationMs == this.ocrDurationMs &&
          other.parserDurationMs == this.parserDurationMs &&
          other.imageQualityScore == this.imageQualityScore &&
          other.parserSource == this.parserSource &&
          other.parserVersion == this.parserVersion);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> company;
  final Value<String?> designation;
  final Value<String> phonesJson;
  final Value<String> emailsJson;
  final Value<String?> website;
  final Value<String?> address;
  final Value<String?> imageFrontPath;
  final Value<String?> imageBackPath;
  final Value<String> confidenceJson;
  final Value<String> parseMode;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> lastContactedAt;
  final Value<bool> isFavorite;
  final Value<String> tagsJson;
  final Value<String?> reminderNote;
  final Value<DateTime?> reminderDate;
  final Value<bool> reminderDone;
  final Value<int> scanCount;
  final Value<String?> linkedInUrl;
  final Value<String?> twitterHandle;
  final Value<String?> aiModelUsed;
  final Value<int?> processingDurationMs;
  final Value<int?> ocrDurationMs;
  final Value<int?> parserDurationMs;
  final Value<double?> imageQualityScore;
  final Value<String> parserSource;
  final Value<int> parserVersion;
  final Value<int> rowid;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.company = const Value.absent(),
    this.designation = const Value.absent(),
    this.phonesJson = const Value.absent(),
    this.emailsJson = const Value.absent(),
    this.website = const Value.absent(),
    this.address = const Value.absent(),
    this.imageFrontPath = const Value.absent(),
    this.imageBackPath = const Value.absent(),
    this.confidenceJson = const Value.absent(),
    this.parseMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastContactedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.reminderNote = const Value.absent(),
    this.reminderDate = const Value.absent(),
    this.reminderDone = const Value.absent(),
    this.scanCount = const Value.absent(),
    this.linkedInUrl = const Value.absent(),
    this.twitterHandle = const Value.absent(),
    this.aiModelUsed = const Value.absent(),
    this.processingDurationMs = const Value.absent(),
    this.ocrDurationMs = const Value.absent(),
    this.parserDurationMs = const Value.absent(),
    this.imageQualityScore = const Value.absent(),
    this.parserSource = const Value.absent(),
    this.parserVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String id,
    required String name,
    this.company = const Value.absent(),
    this.designation = const Value.absent(),
    required String phonesJson,
    required String emailsJson,
    this.website = const Value.absent(),
    this.address = const Value.absent(),
    this.imageFrontPath = const Value.absent(),
    this.imageBackPath = const Value.absent(),
    required String confidenceJson,
    required String parseMode,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.lastContactedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.reminderNote = const Value.absent(),
    this.reminderDate = const Value.absent(),
    this.reminderDone = const Value.absent(),
    this.scanCount = const Value.absent(),
    this.linkedInUrl = const Value.absent(),
    this.twitterHandle = const Value.absent(),
    this.aiModelUsed = const Value.absent(),
    this.processingDurationMs = const Value.absent(),
    this.ocrDurationMs = const Value.absent(),
    this.parserDurationMs = const Value.absent(),
    this.imageQualityScore = const Value.absent(),
    this.parserSource = const Value.absent(),
    this.parserVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        phonesJson = Value(phonesJson),
        emailsJson = Value(emailsJson),
        confidenceJson = Value(confidenceJson),
        parseMode = Value(parseMode),
        createdAt = Value(createdAt);
  static Insertable<Contact> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? company,
    Expression<String>? designation,
    Expression<String>? phonesJson,
    Expression<String>? emailsJson,
    Expression<String>? website,
    Expression<String>? address,
    Expression<String>? imageFrontPath,
    Expression<String>? imageBackPath,
    Expression<String>? confidenceJson,
    Expression<String>? parseMode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastContactedAt,
    Expression<bool>? isFavorite,
    Expression<String>? tagsJson,
    Expression<String>? reminderNote,
    Expression<DateTime>? reminderDate,
    Expression<bool>? reminderDone,
    Expression<int>? scanCount,
    Expression<String>? linkedInUrl,
    Expression<String>? twitterHandle,
    Expression<String>? aiModelUsed,
    Expression<int>? processingDurationMs,
    Expression<int>? ocrDurationMs,
    Expression<int>? parserDurationMs,
    Expression<double>? imageQualityScore,
    Expression<String>? parserSource,
    Expression<int>? parserVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (company != null) 'company': company,
      if (designation != null) 'designation': designation,
      if (phonesJson != null) 'phones_json': phonesJson,
      if (emailsJson != null) 'emails_json': emailsJson,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (imageFrontPath != null) 'image_front_path': imageFrontPath,
      if (imageBackPath != null) 'image_back_path': imageBackPath,
      if (confidenceJson != null) 'confidence_json': confidenceJson,
      if (parseMode != null) 'parse_mode': parseMode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastContactedAt != null) 'last_contacted_at': lastContactedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (reminderNote != null) 'reminder_note': reminderNote,
      if (reminderDate != null) 'reminder_date': reminderDate,
      if (reminderDone != null) 'reminder_done': reminderDone,
      if (scanCount != null) 'scan_count': scanCount,
      if (linkedInUrl != null) 'linked_in_url': linkedInUrl,
      if (twitterHandle != null) 'twitter_handle': twitterHandle,
      if (aiModelUsed != null) 'ai_model_used': aiModelUsed,
      if (processingDurationMs != null)
        'processing_duration_ms': processingDurationMs,
      if (ocrDurationMs != null) 'ocr_duration_ms': ocrDurationMs,
      if (parserDurationMs != null) 'parser_duration_ms': parserDurationMs,
      if (imageQualityScore != null) 'image_quality_score': imageQualityScore,
      if (parserSource != null) 'parser_source': parserSource,
      if (parserVersion != null) 'parser_version': parserVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? company,
      Value<String?>? designation,
      Value<String>? phonesJson,
      Value<String>? emailsJson,
      Value<String?>? website,
      Value<String?>? address,
      Value<String?>? imageFrontPath,
      Value<String?>? imageBackPath,
      Value<String>? confidenceJson,
      Value<String>? parseMode,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? lastContactedAt,
      Value<bool>? isFavorite,
      Value<String>? tagsJson,
      Value<String?>? reminderNote,
      Value<DateTime?>? reminderDate,
      Value<bool>? reminderDone,
      Value<int>? scanCount,
      Value<String?>? linkedInUrl,
      Value<String?>? twitterHandle,
      Value<String?>? aiModelUsed,
      Value<int?>? processingDurationMs,
      Value<int?>? ocrDurationMs,
      Value<int?>? parserDurationMs,
      Value<double?>? imageQualityScore,
      Value<String>? parserSource,
      Value<int>? parserVersion,
      Value<int>? rowid}) {
    return ContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      designation: designation ?? this.designation,
      phonesJson: phonesJson ?? this.phonesJson,
      emailsJson: emailsJson ?? this.emailsJson,
      website: website ?? this.website,
      address: address ?? this.address,
      imageFrontPath: imageFrontPath ?? this.imageFrontPath,
      imageBackPath: imageBackPath ?? this.imageBackPath,
      confidenceJson: confidenceJson ?? this.confidenceJson,
      parseMode: parseMode ?? this.parseMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tagsJson: tagsJson ?? this.tagsJson,
      reminderNote: reminderNote ?? this.reminderNote,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderDone: reminderDone ?? this.reminderDone,
      scanCount: scanCount ?? this.scanCount,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      twitterHandle: twitterHandle ?? this.twitterHandle,
      aiModelUsed: aiModelUsed ?? this.aiModelUsed,
      processingDurationMs: processingDurationMs ?? this.processingDurationMs,
      ocrDurationMs: ocrDurationMs ?? this.ocrDurationMs,
      parserDurationMs: parserDurationMs ?? this.parserDurationMs,
      imageQualityScore: imageQualityScore ?? this.imageQualityScore,
      parserSource: parserSource ?? this.parserSource,
      parserVersion: parserVersion ?? this.parserVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (designation.present) {
      map['designation'] = Variable<String>(designation.value);
    }
    if (phonesJson.present) {
      map['phones_json'] = Variable<String>(phonesJson.value);
    }
    if (emailsJson.present) {
      map['emails_json'] = Variable<String>(emailsJson.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (imageFrontPath.present) {
      map['image_front_path'] = Variable<String>(imageFrontPath.value);
    }
    if (imageBackPath.present) {
      map['image_back_path'] = Variable<String>(imageBackPath.value);
    }
    if (confidenceJson.present) {
      map['confidence_json'] = Variable<String>(confidenceJson.value);
    }
    if (parseMode.present) {
      map['parse_mode'] = Variable<String>(parseMode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastContactedAt.present) {
      map['last_contacted_at'] = Variable<DateTime>(lastContactedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (reminderNote.present) {
      map['reminder_note'] = Variable<String>(reminderNote.value);
    }
    if (reminderDate.present) {
      map['reminder_date'] = Variable<DateTime>(reminderDate.value);
    }
    if (reminderDone.present) {
      map['reminder_done'] = Variable<bool>(reminderDone.value);
    }
    if (scanCount.present) {
      map['scan_count'] = Variable<int>(scanCount.value);
    }
    if (linkedInUrl.present) {
      map['linked_in_url'] = Variable<String>(linkedInUrl.value);
    }
    if (twitterHandle.present) {
      map['twitter_handle'] = Variable<String>(twitterHandle.value);
    }
    if (aiModelUsed.present) {
      map['ai_model_used'] = Variable<String>(aiModelUsed.value);
    }
    if (processingDurationMs.present) {
      map['processing_duration_ms'] = Variable<int>(processingDurationMs.value);
    }
    if (ocrDurationMs.present) {
      map['ocr_duration_ms'] = Variable<int>(ocrDurationMs.value);
    }
    if (parserDurationMs.present) {
      map['parser_duration_ms'] = Variable<int>(parserDurationMs.value);
    }
    if (imageQualityScore.present) {
      map['image_quality_score'] = Variable<double>(imageQualityScore.value);
    }
    if (parserSource.present) {
      map['parser_source'] = Variable<String>(parserSource.value);
    }
    if (parserVersion.present) {
      map['parser_version'] = Variable<int>(parserVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('designation: $designation, ')
          ..write('phonesJson: $phonesJson, ')
          ..write('emailsJson: $emailsJson, ')
          ..write('website: $website, ')
          ..write('address: $address, ')
          ..write('imageFrontPath: $imageFrontPath, ')
          ..write('imageBackPath: $imageBackPath, ')
          ..write('confidenceJson: $confidenceJson, ')
          ..write('parseMode: $parseMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastContactedAt: $lastContactedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('reminderNote: $reminderNote, ')
          ..write('reminderDate: $reminderDate, ')
          ..write('reminderDone: $reminderDone, ')
          ..write('scanCount: $scanCount, ')
          ..write('linkedInUrl: $linkedInUrl, ')
          ..write('twitterHandle: $twitterHandle, ')
          ..write('aiModelUsed: $aiModelUsed, ')
          ..write('processingDurationMs: $processingDurationMs, ')
          ..write('ocrDurationMs: $ocrDurationMs, ')
          ..write('parserDurationMs: $parserDurationMs, ')
          ..write('imageQualityScore: $imageQualityScore, ')
          ..write('parserSource: $parserSource, ')
          ..write('parserVersion: $parserVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactNotesTable extends ContactNotes
    with TableInfo<$ContactNotesTable, ContactNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (id)'));
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, contactId, body, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_notes';
  @override
  VerificationContext validateIntegrity(Insertable<ContactNote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactNote(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_id'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ContactNotesTable createAlias(String alias) {
    return $ContactNotesTable(attachedDatabase, alias);
  }
}

class ContactNote extends DataClass implements Insertable<ContactNote> {
  final int id;
  final String contactId;
  final String body;
  final DateTime createdAt;
  const ContactNote(
      {required this.id,
      required this.contactId,
      required this.body,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<String>(contactId);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ContactNotesCompanion toCompanion(bool nullToAbsent) {
    return ContactNotesCompanion(
      id: Value(id),
      contactId: Value(contactId),
      body: Value(body),
      createdAt: Value(createdAt),
    );
  }

  factory ContactNote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactNote(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<String>(json['contactId']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<String>(contactId),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ContactNote copyWith(
          {int? id, String? contactId, String? body, DateTime? createdAt}) =>
      ContactNote(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
      );
  ContactNote copyWithCompanion(ContactNotesCompanion data) {
    return ContactNote(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactNote(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contactId, body, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactNote &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.body == this.body &&
          other.createdAt == this.createdAt);
}

class ContactNotesCompanion extends UpdateCompanion<ContactNote> {
  final Value<int> id;
  final Value<String> contactId;
  final Value<String> body;
  final Value<DateTime> createdAt;
  const ContactNotesCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ContactNotesCompanion.insert({
    this.id = const Value.absent(),
    required String contactId,
    required String body,
    required DateTime createdAt,
  })  : contactId = Value(contactId),
        body = Value(body),
        createdAt = Value(createdAt);
  static Insertable<ContactNote> custom({
    Expression<int>? id,
    Expression<String>? contactId,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ContactNotesCompanion copyWith(
      {Value<int>? id,
      Value<String>? contactId,
      Value<String>? body,
      Value<DateTime>? createdAt}) {
    return ContactNotesCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactNotesCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ScanDraftsTable extends ScanDrafts
    with TableInfo<$ScanDraftsTable, ScanDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parseResultJsonMeta =
      const VerificationMeta('parseResultJson');
  @override
  late final GeneratedColumn<String> parseResultJson = GeneratedColumn<String>(
      'parse_result_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageFrontPathMeta =
      const VerificationMeta('imageFrontPath');
  @override
  late final GeneratedColumn<String> imageFrontPath = GeneratedColumn<String>(
      'image_front_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageBackPathMeta =
      const VerificationMeta('imageBackPath');
  @override
  late final GeneratedColumn<String> imageBackPath = GeneratedColumn<String>(
      'image_back_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, parseResultJson, imageFrontPath, imageBackPath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_drafts';
  @override
  VerificationContext validateIntegrity(Insertable<ScanDraft> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parse_result_json')) {
      context.handle(
          _parseResultJsonMeta,
          parseResultJson.isAcceptableOrUnknown(
              data['parse_result_json']!, _parseResultJsonMeta));
    } else if (isInserting) {
      context.missing(_parseResultJsonMeta);
    }
    if (data.containsKey('image_front_path')) {
      context.handle(
          _imageFrontPathMeta,
          imageFrontPath.isAcceptableOrUnknown(
              data['image_front_path']!, _imageFrontPathMeta));
    }
    if (data.containsKey('image_back_path')) {
      context.handle(
          _imageBackPathMeta,
          imageBackPath.isAcceptableOrUnknown(
              data['image_back_path']!, _imageBackPathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanDraft(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      parseResultJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parse_result_json'])!,
      imageFrontPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}image_front_path']),
      imageBackPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_back_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ScanDraftsTable createAlias(String alias) {
    return $ScanDraftsTable(attachedDatabase, alias);
  }
}

class ScanDraft extends DataClass implements Insertable<ScanDraft> {
  final String id;
  final String parseResultJson;
  final String? imageFrontPath;
  final String? imageBackPath;
  final DateTime createdAt;
  const ScanDraft(
      {required this.id,
      required this.parseResultJson,
      this.imageFrontPath,
      this.imageBackPath,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['parse_result_json'] = Variable<String>(parseResultJson);
    if (!nullToAbsent || imageFrontPath != null) {
      map['image_front_path'] = Variable<String>(imageFrontPath);
    }
    if (!nullToAbsent || imageBackPath != null) {
      map['image_back_path'] = Variable<String>(imageBackPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScanDraftsCompanion toCompanion(bool nullToAbsent) {
    return ScanDraftsCompanion(
      id: Value(id),
      parseResultJson: Value(parseResultJson),
      imageFrontPath: imageFrontPath == null && nullToAbsent
          ? const Value.absent()
          : Value(imageFrontPath),
      imageBackPath: imageBackPath == null && nullToAbsent
          ? const Value.absent()
          : Value(imageBackPath),
      createdAt: Value(createdAt),
    );
  }

  factory ScanDraft.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanDraft(
      id: serializer.fromJson<String>(json['id']),
      parseResultJson: serializer.fromJson<String>(json['parseResultJson']),
      imageFrontPath: serializer.fromJson<String?>(json['imageFrontPath']),
      imageBackPath: serializer.fromJson<String?>(json['imageBackPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parseResultJson': serializer.toJson<String>(parseResultJson),
      'imageFrontPath': serializer.toJson<String?>(imageFrontPath),
      'imageBackPath': serializer.toJson<String?>(imageBackPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScanDraft copyWith(
          {String? id,
          String? parseResultJson,
          Value<String?> imageFrontPath = const Value.absent(),
          Value<String?> imageBackPath = const Value.absent(),
          DateTime? createdAt}) =>
      ScanDraft(
        id: id ?? this.id,
        parseResultJson: parseResultJson ?? this.parseResultJson,
        imageFrontPath:
            imageFrontPath.present ? imageFrontPath.value : this.imageFrontPath,
        imageBackPath:
            imageBackPath.present ? imageBackPath.value : this.imageBackPath,
        createdAt: createdAt ?? this.createdAt,
      );
  ScanDraft copyWithCompanion(ScanDraftsCompanion data) {
    return ScanDraft(
      id: data.id.present ? data.id.value : this.id,
      parseResultJson: data.parseResultJson.present
          ? data.parseResultJson.value
          : this.parseResultJson,
      imageFrontPath: data.imageFrontPath.present
          ? data.imageFrontPath.value
          : this.imageFrontPath,
      imageBackPath: data.imageBackPath.present
          ? data.imageBackPath.value
          : this.imageBackPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanDraft(')
          ..write('id: $id, ')
          ..write('parseResultJson: $parseResultJson, ')
          ..write('imageFrontPath: $imageFrontPath, ')
          ..write('imageBackPath: $imageBackPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, parseResultJson, imageFrontPath, imageBackPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanDraft &&
          other.id == this.id &&
          other.parseResultJson == this.parseResultJson &&
          other.imageFrontPath == this.imageFrontPath &&
          other.imageBackPath == this.imageBackPath &&
          other.createdAt == this.createdAt);
}

class ScanDraftsCompanion extends UpdateCompanion<ScanDraft> {
  final Value<String> id;
  final Value<String> parseResultJson;
  final Value<String?> imageFrontPath;
  final Value<String?> imageBackPath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ScanDraftsCompanion({
    this.id = const Value.absent(),
    this.parseResultJson = const Value.absent(),
    this.imageFrontPath = const Value.absent(),
    this.imageBackPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanDraftsCompanion.insert({
    required String id,
    required String parseResultJson,
    this.imageFrontPath = const Value.absent(),
    this.imageBackPath = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        parseResultJson = Value(parseResultJson),
        createdAt = Value(createdAt);
  static Insertable<ScanDraft> custom({
    Expression<String>? id,
    Expression<String>? parseResultJson,
    Expression<String>? imageFrontPath,
    Expression<String>? imageBackPath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parseResultJson != null) 'parse_result_json': parseResultJson,
      if (imageFrontPath != null) 'image_front_path': imageFrontPath,
      if (imageBackPath != null) 'image_back_path': imageBackPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanDraftsCompanion copyWith(
      {Value<String>? id,
      Value<String>? parseResultJson,
      Value<String?>? imageFrontPath,
      Value<String?>? imageBackPath,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ScanDraftsCompanion(
      id: id ?? this.id,
      parseResultJson: parseResultJson ?? this.parseResultJson,
      imageFrontPath: imageFrontPath ?? this.imageFrontPath,
      imageBackPath: imageBackPath ?? this.imageBackPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parseResultJson.present) {
      map['parse_result_json'] = Variable<String>(parseResultJson.value);
    }
    if (imageFrontPath.present) {
      map['image_front_path'] = Variable<String>(imageFrontPath.value);
    }
    if (imageBackPath.present) {
      map['image_back_path'] = Variable<String>(imageBackPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanDraftsCompanion(')
          ..write('id: $id, ')
          ..write('parseResultJson: $parseResultJson, ')
          ..write('imageFrontPath: $imageFrontPath, ')
          ..write('imageBackPath: $imageBackPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParserCorrectionsTable extends ParserCorrections
    with TableInfo<$ParserCorrectionsTable, ParserCorrection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParserCorrectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (id)'));
  static const VerificationMeta _fieldNameMeta =
      const VerificationMeta('fieldName');
  @override
  late final GeneratedColumn<String> fieldName = GeneratedColumn<String>(
      'field_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originalOcrMeta =
      const VerificationMeta('originalOcr');
  @override
  late final GeneratedColumn<String> originalOcr = GeneratedColumn<String>(
      'original_ocr', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originalParsedMeta =
      const VerificationMeta('originalParsed');
  @override
  late final GeneratedColumn<String> originalParsed = GeneratedColumn<String>(
      'original_parsed', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctedValueMeta =
      const VerificationMeta('correctedValue');
  @override
  late final GeneratedColumn<String> correctedValue = GeneratedColumn<String>(
      'corrected_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldTypeMeta =
      const VerificationMeta('fieldType');
  @override
  late final GeneratedColumn<String> fieldType = GeneratedColumn<String>(
      'field_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        contactId,
        fieldName,
        originalOcr,
        originalParsed,
        correctedValue,
        fieldType,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parser_corrections';
  @override
  VerificationContext validateIntegrity(Insertable<ParserCorrection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('field_name')) {
      context.handle(_fieldNameMeta,
          fieldName.isAcceptableOrUnknown(data['field_name']!, _fieldNameMeta));
    } else if (isInserting) {
      context.missing(_fieldNameMeta);
    }
    if (data.containsKey('original_ocr')) {
      context.handle(
          _originalOcrMeta,
          originalOcr.isAcceptableOrUnknown(
              data['original_ocr']!, _originalOcrMeta));
    } else if (isInserting) {
      context.missing(_originalOcrMeta);
    }
    if (data.containsKey('original_parsed')) {
      context.handle(
          _originalParsedMeta,
          originalParsed.isAcceptableOrUnknown(
              data['original_parsed']!, _originalParsedMeta));
    } else if (isInserting) {
      context.missing(_originalParsedMeta);
    }
    if (data.containsKey('corrected_value')) {
      context.handle(
          _correctedValueMeta,
          correctedValue.isAcceptableOrUnknown(
              data['corrected_value']!, _correctedValueMeta));
    } else if (isInserting) {
      context.missing(_correctedValueMeta);
    }
    if (data.containsKey('field_type')) {
      context.handle(_fieldTypeMeta,
          fieldType.isAcceptableOrUnknown(data['field_type']!, _fieldTypeMeta));
    } else if (isInserting) {
      context.missing(_fieldTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParserCorrection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParserCorrection(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_id'])!,
      fieldName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_name'])!,
      originalOcr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_ocr'])!,
      originalParsed: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_parsed'])!,
      correctedValue: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}corrected_value'])!,
      fieldType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ParserCorrectionsTable createAlias(String alias) {
    return $ParserCorrectionsTable(attachedDatabase, alias);
  }
}

class ParserCorrection extends DataClass
    implements Insertable<ParserCorrection> {
  final int id;
  final String contactId;
  final String fieldName;
  final String originalOcr;
  final String originalParsed;
  final String correctedValue;
  final String fieldType;
  final DateTime createdAt;
  const ParserCorrection(
      {required this.id,
      required this.contactId,
      required this.fieldName,
      required this.originalOcr,
      required this.originalParsed,
      required this.correctedValue,
      required this.fieldType,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<String>(contactId);
    map['field_name'] = Variable<String>(fieldName);
    map['original_ocr'] = Variable<String>(originalOcr);
    map['original_parsed'] = Variable<String>(originalParsed);
    map['corrected_value'] = Variable<String>(correctedValue);
    map['field_type'] = Variable<String>(fieldType);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ParserCorrectionsCompanion toCompanion(bool nullToAbsent) {
    return ParserCorrectionsCompanion(
      id: Value(id),
      contactId: Value(contactId),
      fieldName: Value(fieldName),
      originalOcr: Value(originalOcr),
      originalParsed: Value(originalParsed),
      correctedValue: Value(correctedValue),
      fieldType: Value(fieldType),
      createdAt: Value(createdAt),
    );
  }

  factory ParserCorrection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParserCorrection(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<String>(json['contactId']),
      fieldName: serializer.fromJson<String>(json['fieldName']),
      originalOcr: serializer.fromJson<String>(json['originalOcr']),
      originalParsed: serializer.fromJson<String>(json['originalParsed']),
      correctedValue: serializer.fromJson<String>(json['correctedValue']),
      fieldType: serializer.fromJson<String>(json['fieldType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<String>(contactId),
      'fieldName': serializer.toJson<String>(fieldName),
      'originalOcr': serializer.toJson<String>(originalOcr),
      'originalParsed': serializer.toJson<String>(originalParsed),
      'correctedValue': serializer.toJson<String>(correctedValue),
      'fieldType': serializer.toJson<String>(fieldType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ParserCorrection copyWith(
          {int? id,
          String? contactId,
          String? fieldName,
          String? originalOcr,
          String? originalParsed,
          String? correctedValue,
          String? fieldType,
          DateTime? createdAt}) =>
      ParserCorrection(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        fieldName: fieldName ?? this.fieldName,
        originalOcr: originalOcr ?? this.originalOcr,
        originalParsed: originalParsed ?? this.originalParsed,
        correctedValue: correctedValue ?? this.correctedValue,
        fieldType: fieldType ?? this.fieldType,
        createdAt: createdAt ?? this.createdAt,
      );
  ParserCorrection copyWithCompanion(ParserCorrectionsCompanion data) {
    return ParserCorrection(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      fieldName: data.fieldName.present ? data.fieldName.value : this.fieldName,
      originalOcr:
          data.originalOcr.present ? data.originalOcr.value : this.originalOcr,
      originalParsed: data.originalParsed.present
          ? data.originalParsed.value
          : this.originalParsed,
      correctedValue: data.correctedValue.present
          ? data.correctedValue.value
          : this.correctedValue,
      fieldType: data.fieldType.present ? data.fieldType.value : this.fieldType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParserCorrection(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('fieldName: $fieldName, ')
          ..write('originalOcr: $originalOcr, ')
          ..write('originalParsed: $originalParsed, ')
          ..write('correctedValue: $correctedValue, ')
          ..write('fieldType: $fieldType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contactId, fieldName, originalOcr,
      originalParsed, correctedValue, fieldType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParserCorrection &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.fieldName == this.fieldName &&
          other.originalOcr == this.originalOcr &&
          other.originalParsed == this.originalParsed &&
          other.correctedValue == this.correctedValue &&
          other.fieldType == this.fieldType &&
          other.createdAt == this.createdAt);
}

class ParserCorrectionsCompanion extends UpdateCompanion<ParserCorrection> {
  final Value<int> id;
  final Value<String> contactId;
  final Value<String> fieldName;
  final Value<String> originalOcr;
  final Value<String> originalParsed;
  final Value<String> correctedValue;
  final Value<String> fieldType;
  final Value<DateTime> createdAt;
  const ParserCorrectionsCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.fieldName = const Value.absent(),
    this.originalOcr = const Value.absent(),
    this.originalParsed = const Value.absent(),
    this.correctedValue = const Value.absent(),
    this.fieldType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ParserCorrectionsCompanion.insert({
    this.id = const Value.absent(),
    required String contactId,
    required String fieldName,
    required String originalOcr,
    required String originalParsed,
    required String correctedValue,
    required String fieldType,
    required DateTime createdAt,
  })  : contactId = Value(contactId),
        fieldName = Value(fieldName),
        originalOcr = Value(originalOcr),
        originalParsed = Value(originalParsed),
        correctedValue = Value(correctedValue),
        fieldType = Value(fieldType),
        createdAt = Value(createdAt);
  static Insertable<ParserCorrection> custom({
    Expression<int>? id,
    Expression<String>? contactId,
    Expression<String>? fieldName,
    Expression<String>? originalOcr,
    Expression<String>? originalParsed,
    Expression<String>? correctedValue,
    Expression<String>? fieldType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (fieldName != null) 'field_name': fieldName,
      if (originalOcr != null) 'original_ocr': originalOcr,
      if (originalParsed != null) 'original_parsed': originalParsed,
      if (correctedValue != null) 'corrected_value': correctedValue,
      if (fieldType != null) 'field_type': fieldType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ParserCorrectionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? contactId,
      Value<String>? fieldName,
      Value<String>? originalOcr,
      Value<String>? originalParsed,
      Value<String>? correctedValue,
      Value<String>? fieldType,
      Value<DateTime>? createdAt}) {
    return ParserCorrectionsCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      fieldName: fieldName ?? this.fieldName,
      originalOcr: originalOcr ?? this.originalOcr,
      originalParsed: originalParsed ?? this.originalParsed,
      correctedValue: correctedValue ?? this.correctedValue,
      fieldType: fieldType ?? this.fieldType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (fieldName.present) {
      map['field_name'] = Variable<String>(fieldName.value);
    }
    if (originalOcr.present) {
      map['original_ocr'] = Variable<String>(originalOcr.value);
    }
    if (originalParsed.present) {
      map['original_parsed'] = Variable<String>(originalParsed.value);
    }
    if (correctedValue.present) {
      map['corrected_value'] = Variable<String>(correctedValue.value);
    }
    if (fieldType.present) {
      map['field_type'] = Variable<String>(fieldType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParserCorrectionsCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('fieldName: $fieldName, ')
          ..write('originalOcr: $originalOcr, ')
          ..write('originalParsed: $originalParsed, ')
          ..write('correctedValue: $correctedValue, ')
          ..write('fieldType: $fieldType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ContactFtsTable extends ContactFts
    with TableInfo<$ContactFtsTable, ContactFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactFtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
      'rowid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _companyMeta =
      const VerificationMeta('company');
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
      'company', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _designationMeta =
      const VerificationMeta('designation');
  @override
  late final GeneratedColumn<String> designation = GeneratedColumn<String>(
      'designation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [contactId, name, company, designation, email, phone];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_fts';
  @override
  VerificationContext validateIntegrity(Insertable<ContactFt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('rowid')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['rowid']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('company')) {
      context.handle(_companyMeta,
          company.isAcceptableOrUnknown(data['company']!, _companyMeta));
    } else if (isInserting) {
      context.missing(_companyMeta);
    }
    if (data.containsKey('designation')) {
      context.handle(
          _designationMeta,
          designation.isAcceptableOrUnknown(
              data['designation']!, _designationMeta));
    } else if (isInserting) {
      context.missing(_designationMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ContactFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactFt(
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rowid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      company: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company'])!,
      designation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}designation'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
    );
  }

  @override
  $ContactFtsTable createAlias(String alias) {
    return $ContactFtsTable(attachedDatabase, alias);
  }
}

class ContactFt extends DataClass implements Insertable<ContactFt> {
  final String contactId;
  final String name;
  final String company;
  final String designation;
  final String email;
  final String phone;
  const ContactFt(
      {required this.contactId,
      required this.name,
      required this.company,
      required this.designation,
      required this.email,
      required this.phone});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['rowid'] = Variable<String>(contactId);
    map['name'] = Variable<String>(name);
    map['company'] = Variable<String>(company);
    map['designation'] = Variable<String>(designation);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<String>(phone);
    return map;
  }

  ContactFtsCompanion toCompanion(bool nullToAbsent) {
    return ContactFtsCompanion(
      contactId: Value(contactId),
      name: Value(name),
      company: Value(company),
      designation: Value(designation),
      email: Value(email),
      phone: Value(phone),
    );
  }

  factory ContactFt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactFt(
      contactId: serializer.fromJson<String>(json['contactId']),
      name: serializer.fromJson<String>(json['name']),
      company: serializer.fromJson<String>(json['company']),
      designation: serializer.fromJson<String>(json['designation']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contactId': serializer.toJson<String>(contactId),
      'name': serializer.toJson<String>(name),
      'company': serializer.toJson<String>(company),
      'designation': serializer.toJson<String>(designation),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
    };
  }

  ContactFt copyWith(
          {String? contactId,
          String? name,
          String? company,
          String? designation,
          String? email,
          String? phone}) =>
      ContactFt(
        contactId: contactId ?? this.contactId,
        name: name ?? this.name,
        company: company ?? this.company,
        designation: designation ?? this.designation,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );
  ContactFt copyWithCompanion(ContactFtsCompanion data) {
    return ContactFt(
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      name: data.name.present ? data.name.value : this.name,
      company: data.company.present ? data.company.value : this.company,
      designation:
          data.designation.present ? data.designation.value : this.designation,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactFt(')
          ..write('contactId: $contactId, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('designation: $designation, ')
          ..write('email: $email, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(contactId, name, company, designation, email, phone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactFt &&
          other.contactId == this.contactId &&
          other.name == this.name &&
          other.company == this.company &&
          other.designation == this.designation &&
          other.email == this.email &&
          other.phone == this.phone);
}

class ContactFtsCompanion extends UpdateCompanion<ContactFt> {
  final Value<String> contactId;
  final Value<String> name;
  final Value<String> company;
  final Value<String> designation;
  final Value<String> email;
  final Value<String> phone;
  final Value<int> rowid;
  const ContactFtsCompanion({
    this.contactId = const Value.absent(),
    this.name = const Value.absent(),
    this.company = const Value.absent(),
    this.designation = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactFtsCompanion.insert({
    required String contactId,
    required String name,
    required String company,
    required String designation,
    required String email,
    required String phone,
    this.rowid = const Value.absent(),
  })  : contactId = Value(contactId),
        name = Value(name),
        company = Value(company),
        designation = Value(designation),
        email = Value(email),
        phone = Value(phone);
  static Insertable<ContactFt> custom({
    Expression<String>? contactId,
    Expression<String>? name,
    Expression<String>? company,
    Expression<String>? designation,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contactId != null) 'rowid': contactId,
      if (name != null) 'name': name,
      if (company != null) 'company': company,
      if (designation != null) 'designation': designation,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactFtsCompanion copyWith(
      {Value<String>? contactId,
      Value<String>? name,
      Value<String>? company,
      Value<String>? designation,
      Value<String>? email,
      Value<String>? phone,
      Value<int>? rowid}) {
    return ContactFtsCompanion(
      contactId: contactId ?? this.contactId,
      name: name ?? this.name,
      company: company ?? this.company,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contactId.present) {
      map['rowid'] = Variable<String>(contactId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (designation.present) {
      map['designation'] = Variable<String>(designation.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactFtsCompanion(')
          ..write('contactId: $contactId, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('designation: $designation, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $ContactNotesTable contactNotes = $ContactNotesTable(this);
  late final $ScanDraftsTable scanDrafts = $ScanDraftsTable(this);
  late final $ParserCorrectionsTable parserCorrections =
      $ParserCorrectionsTable(this);
  late final $ContactFtsTable contactFts = $ContactFtsTable(this);
  late final ContactsDao contactsDao = ContactsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [contacts, contactNotes, scanDrafts, parserCorrections, contactFts];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  required String id,
  required String name,
  Value<String?> company,
  Value<String?> designation,
  required String phonesJson,
  required String emailsJson,
  Value<String?> website,
  Value<String?> address,
  Value<String?> imageFrontPath,
  Value<String?> imageBackPath,
  required String confidenceJson,
  required String parseMode,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<DateTime?> lastContactedAt,
  Value<bool> isFavorite,
  Value<String> tagsJson,
  Value<String?> reminderNote,
  Value<DateTime?> reminderDate,
  Value<bool> reminderDone,
  Value<int> scanCount,
  Value<String?> linkedInUrl,
  Value<String?> twitterHandle,
  Value<String?> aiModelUsed,
  Value<int?> processingDurationMs,
  Value<int?> ocrDurationMs,
  Value<int?> parserDurationMs,
  Value<double?> imageQualityScore,
  Value<String> parserSource,
  Value<int> parserVersion,
  Value<int> rowid,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> company,
  Value<String?> designation,
  Value<String> phonesJson,
  Value<String> emailsJson,
  Value<String?> website,
  Value<String?> address,
  Value<String?> imageFrontPath,
  Value<String?> imageBackPath,
  Value<String> confidenceJson,
  Value<String> parseMode,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<DateTime?> lastContactedAt,
  Value<bool> isFavorite,
  Value<String> tagsJson,
  Value<String?> reminderNote,
  Value<DateTime?> reminderDate,
  Value<bool> reminderDone,
  Value<int> scanCount,
  Value<String?> linkedInUrl,
  Value<String?> twitterHandle,
  Value<String?> aiModelUsed,
  Value<int?> processingDurationMs,
  Value<int?> ocrDurationMs,
  Value<int?> parserDurationMs,
  Value<double?> imageQualityScore,
  Value<String> parserSource,
  Value<int> parserVersion,
  Value<int> rowid,
});

final class $$ContactsTableReferences
    extends BaseReferences<_$AppDatabase, $ContactsTable, Contact> {
  $$ContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ContactNotesTable, List<ContactNote>>
      _contactNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.contactNotes,
          aliasName:
              $_aliasNameGenerator(db.contacts.id, db.contactNotes.contactId));

  $$ContactNotesTableProcessedTableManager get contactNotesRefs {
    final manager = $$ContactNotesTableTableManager($_db, $_db.contactNotes)
        .filter((f) => f.contactId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contactNotesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ParserCorrectionsTable, List<ParserCorrection>>
      _parserCorrectionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.parserCorrections,
              aliasName: $_aliasNameGenerator(
                  db.contacts.id, db.parserCorrections.contactId));

  $$ParserCorrectionsTableProcessedTableManager get parserCorrectionsRefs {
    final manager = $$ParserCorrectionsTableTableManager(
            $_db, $_db.parserCorrections)
        .filter((f) => f.contactId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_parserCorrectionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get company => $composableBuilder(
      column: $table.company, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phonesJson => $composableBuilder(
      column: $table.phonesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emailsJson => $composableBuilder(
      column: $table.emailsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageFrontPath => $composableBuilder(
      column: $table.imageFrontPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageBackPath => $composableBuilder(
      column: $table.imageBackPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidenceJson => $composableBuilder(
      column: $table.confidenceJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parseMode => $composableBuilder(
      column: $table.parseMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastContactedAt => $composableBuilder(
      column: $table.lastContactedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderNote => $composableBuilder(
      column: $table.reminderNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reminderDate => $composableBuilder(
      column: $table.reminderDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get reminderDone => $composableBuilder(
      column: $table.reminderDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scanCount => $composableBuilder(
      column: $table.scanCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedInUrl => $composableBuilder(
      column: $table.linkedInUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get twitterHandle => $composableBuilder(
      column: $table.twitterHandle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiModelUsed => $composableBuilder(
      column: $table.aiModelUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get processingDurationMs => $composableBuilder(
      column: $table.processingDurationMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ocrDurationMs => $composableBuilder(
      column: $table.ocrDurationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parserDurationMs => $composableBuilder(
      column: $table.parserDurationMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get imageQualityScore => $composableBuilder(
      column: $table.imageQualityScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parserSource => $composableBuilder(
      column: $table.parserSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parserVersion => $composableBuilder(
      column: $table.parserVersion, builder: (column) => ColumnFilters(column));

  Expression<bool> contactNotesRefs(
      Expression<bool> Function($$ContactNotesTableFilterComposer f) f) {
    final $$ContactNotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.contactNotes,
        getReferencedColumn: (t) => t.contactId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactNotesTableFilterComposer(
              $db: $db,
              $table: $db.contactNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> parserCorrectionsRefs(
      Expression<bool> Function($$ParserCorrectionsTableFilterComposer f) f) {
    final $$ParserCorrectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.parserCorrections,
        getReferencedColumn: (t) => t.contactId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParserCorrectionsTableFilterComposer(
              $db: $db,
              $table: $db.parserCorrections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get company => $composableBuilder(
      column: $table.company, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phonesJson => $composableBuilder(
      column: $table.phonesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emailsJson => $composableBuilder(
      column: $table.emailsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageFrontPath => $composableBuilder(
      column: $table.imageFrontPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageBackPath => $composableBuilder(
      column: $table.imageBackPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidenceJson => $composableBuilder(
      column: $table.confidenceJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parseMode => $composableBuilder(
      column: $table.parseMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastContactedAt => $composableBuilder(
      column: $table.lastContactedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderNote => $composableBuilder(
      column: $table.reminderNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reminderDate => $composableBuilder(
      column: $table.reminderDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get reminderDone => $composableBuilder(
      column: $table.reminderDone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scanCount => $composableBuilder(
      column: $table.scanCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedInUrl => $composableBuilder(
      column: $table.linkedInUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get twitterHandle => $composableBuilder(
      column: $table.twitterHandle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiModelUsed => $composableBuilder(
      column: $table.aiModelUsed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get processingDurationMs => $composableBuilder(
      column: $table.processingDurationMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ocrDurationMs => $composableBuilder(
      column: $table.ocrDurationMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parserDurationMs => $composableBuilder(
      column: $table.parserDurationMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get imageQualityScore => $composableBuilder(
      column: $table.imageQualityScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parserSource => $composableBuilder(
      column: $table.parserSource,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parserVersion => $composableBuilder(
      column: $table.parserVersion,
      builder: (column) => ColumnOrderings(column));
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => column);

  GeneratedColumn<String> get phonesJson => $composableBuilder(
      column: $table.phonesJson, builder: (column) => column);

  GeneratedColumn<String> get emailsJson => $composableBuilder(
      column: $table.emailsJson, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get imageFrontPath => $composableBuilder(
      column: $table.imageFrontPath, builder: (column) => column);

  GeneratedColumn<String> get imageBackPath => $composableBuilder(
      column: $table.imageBackPath, builder: (column) => column);

  GeneratedColumn<String> get confidenceJson => $composableBuilder(
      column: $table.confidenceJson, builder: (column) => column);

  GeneratedColumn<String> get parseMode =>
      $composableBuilder(column: $table.parseMode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastContactedAt => $composableBuilder(
      column: $table.lastContactedAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get reminderNote => $composableBuilder(
      column: $table.reminderNote, builder: (column) => column);

  GeneratedColumn<DateTime> get reminderDate => $composableBuilder(
      column: $table.reminderDate, builder: (column) => column);

  GeneratedColumn<bool> get reminderDone => $composableBuilder(
      column: $table.reminderDone, builder: (column) => column);

  GeneratedColumn<int> get scanCount =>
      $composableBuilder(column: $table.scanCount, builder: (column) => column);

  GeneratedColumn<String> get linkedInUrl => $composableBuilder(
      column: $table.linkedInUrl, builder: (column) => column);

  GeneratedColumn<String> get twitterHandle => $composableBuilder(
      column: $table.twitterHandle, builder: (column) => column);

  GeneratedColumn<String> get aiModelUsed => $composableBuilder(
      column: $table.aiModelUsed, builder: (column) => column);

  GeneratedColumn<int> get processingDurationMs => $composableBuilder(
      column: $table.processingDurationMs, builder: (column) => column);

  GeneratedColumn<int> get ocrDurationMs => $composableBuilder(
      column: $table.ocrDurationMs, builder: (column) => column);

  GeneratedColumn<int> get parserDurationMs => $composableBuilder(
      column: $table.parserDurationMs, builder: (column) => column);

  GeneratedColumn<double> get imageQualityScore => $composableBuilder(
      column: $table.imageQualityScore, builder: (column) => column);

  GeneratedColumn<String> get parserSource => $composableBuilder(
      column: $table.parserSource, builder: (column) => column);

  GeneratedColumn<int> get parserVersion => $composableBuilder(
      column: $table.parserVersion, builder: (column) => column);

  Expression<T> contactNotesRefs<T extends Object>(
      Expression<T> Function($$ContactNotesTableAnnotationComposer a) f) {
    final $$ContactNotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.contactNotes,
        getReferencedColumn: (t) => t.contactId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactNotesTableAnnotationComposer(
              $db: $db,
              $table: $db.contactNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> parserCorrectionsRefs<T extends Object>(
      Expression<T> Function($$ParserCorrectionsTableAnnotationComposer a) f) {
    final $$ParserCorrectionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.parserCorrections,
            getReferencedColumn: (t) => t.contactId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ParserCorrectionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.parserCorrections,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ContactsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, $$ContactsTableReferences),
    Contact,
    PrefetchHooks Function(
        {bool contactNotesRefs, bool parserCorrectionsRefs})> {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> company = const Value.absent(),
            Value<String?> designation = const Value.absent(),
            Value<String> phonesJson = const Value.absent(),
            Value<String> emailsJson = const Value.absent(),
            Value<String?> website = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> imageFrontPath = const Value.absent(),
            Value<String?> imageBackPath = const Value.absent(),
            Value<String> confidenceJson = const Value.absent(),
            Value<String> parseMode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> lastContactedAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String?> reminderNote = const Value.absent(),
            Value<DateTime?> reminderDate = const Value.absent(),
            Value<bool> reminderDone = const Value.absent(),
            Value<int> scanCount = const Value.absent(),
            Value<String?> linkedInUrl = const Value.absent(),
            Value<String?> twitterHandle = const Value.absent(),
            Value<String?> aiModelUsed = const Value.absent(),
            Value<int?> processingDurationMs = const Value.absent(),
            Value<int?> ocrDurationMs = const Value.absent(),
            Value<int?> parserDurationMs = const Value.absent(),
            Value<double?> imageQualityScore = const Value.absent(),
            Value<String> parserSource = const Value.absent(),
            Value<int> parserVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion(
            id: id,
            name: name,
            company: company,
            designation: designation,
            phonesJson: phonesJson,
            emailsJson: emailsJson,
            website: website,
            address: address,
            imageFrontPath: imageFrontPath,
            imageBackPath: imageBackPath,
            confidenceJson: confidenceJson,
            parseMode: parseMode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastContactedAt: lastContactedAt,
            isFavorite: isFavorite,
            tagsJson: tagsJson,
            reminderNote: reminderNote,
            reminderDate: reminderDate,
            reminderDone: reminderDone,
            scanCount: scanCount,
            linkedInUrl: linkedInUrl,
            twitterHandle: twitterHandle,
            aiModelUsed: aiModelUsed,
            processingDurationMs: processingDurationMs,
            ocrDurationMs: ocrDurationMs,
            parserDurationMs: parserDurationMs,
            imageQualityScore: imageQualityScore,
            parserSource: parserSource,
            parserVersion: parserVersion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> company = const Value.absent(),
            Value<String?> designation = const Value.absent(),
            required String phonesJson,
            required String emailsJson,
            Value<String?> website = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> imageFrontPath = const Value.absent(),
            Value<String?> imageBackPath = const Value.absent(),
            required String confidenceJson,
            required String parseMode,
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> lastContactedAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String?> reminderNote = const Value.absent(),
            Value<DateTime?> reminderDate = const Value.absent(),
            Value<bool> reminderDone = const Value.absent(),
            Value<int> scanCount = const Value.absent(),
            Value<String?> linkedInUrl = const Value.absent(),
            Value<String?> twitterHandle = const Value.absent(),
            Value<String?> aiModelUsed = const Value.absent(),
            Value<int?> processingDurationMs = const Value.absent(),
            Value<int?> ocrDurationMs = const Value.absent(),
            Value<int?> parserDurationMs = const Value.absent(),
            Value<double?> imageQualityScore = const Value.absent(),
            Value<String> parserSource = const Value.absent(),
            Value<int> parserVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion.insert(
            id: id,
            name: name,
            company: company,
            designation: designation,
            phonesJson: phonesJson,
            emailsJson: emailsJson,
            website: website,
            address: address,
            imageFrontPath: imageFrontPath,
            imageBackPath: imageBackPath,
            confidenceJson: confidenceJson,
            parseMode: parseMode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastContactedAt: lastContactedAt,
            isFavorite: isFavorite,
            tagsJson: tagsJson,
            reminderNote: reminderNote,
            reminderDate: reminderDate,
            reminderDone: reminderDone,
            scanCount: scanCount,
            linkedInUrl: linkedInUrl,
            twitterHandle: twitterHandle,
            aiModelUsed: aiModelUsed,
            processingDurationMs: processingDurationMs,
            ocrDurationMs: ocrDurationMs,
            parserDurationMs: parserDurationMs,
            imageQualityScore: imageQualityScore,
            parserSource: parserSource,
            parserVersion: parserVersion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ContactsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {contactNotesRefs = false, parserCorrectionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (contactNotesRefs) db.contactNotes,
                if (parserCorrectionsRefs) db.parserCorrections
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (contactNotesRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable,
                            ContactNote>(
                        currentTable: table,
                        referencedTable: $$ContactsTableReferences
                            ._contactNotesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .contactNotesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactId == item.id),
                        typedResults: items),
                  if (parserCorrectionsRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable,
                            ParserCorrection>(
                        currentTable: table,
                        referencedTable: $$ContactsTableReferences
                            ._parserCorrectionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .parserCorrectionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ContactsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, $$ContactsTableReferences),
    Contact,
    PrefetchHooks Function(
        {bool contactNotesRefs, bool parserCorrectionsRefs})>;
typedef $$ContactNotesTableCreateCompanionBuilder = ContactNotesCompanion
    Function({
  Value<int> id,
  required String contactId,
  required String body,
  required DateTime createdAt,
});
typedef $$ContactNotesTableUpdateCompanionBuilder = ContactNotesCompanion
    Function({
  Value<int> id,
  Value<String> contactId,
  Value<String> body,
  Value<DateTime> createdAt,
});

final class $$ContactNotesTableReferences
    extends BaseReferences<_$AppDatabase, $ContactNotesTable, ContactNote> {
  $$ContactNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactIdTable(_$AppDatabase db) =>
      db.contacts.createAlias(
          $_aliasNameGenerator(db.contactNotes.contactId, db.contacts.id));

  $$ContactsTableProcessedTableManager get contactId {
    final $_column = $_itemColumn<String>('contact_id')!;

    final manager = $$ContactsTableTableManager($_db, $_db.contacts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ContactNotesTableFilterComposer
    extends Composer<_$AppDatabase, $ContactNotesTable> {
  $$ContactNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableFilterComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContactNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactNotesTable> {
  $$ContactNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableOrderingComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContactNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactNotesTable> {
  $$ContactNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableAnnotationComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContactNotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactNotesTable,
    ContactNote,
    $$ContactNotesTableFilterComposer,
    $$ContactNotesTableOrderingComposer,
    $$ContactNotesTableAnnotationComposer,
    $$ContactNotesTableCreateCompanionBuilder,
    $$ContactNotesTableUpdateCompanionBuilder,
    (ContactNote, $$ContactNotesTableReferences),
    ContactNote,
    PrefetchHooks Function({bool contactId})> {
  $$ContactNotesTableTableManager(_$AppDatabase db, $ContactNotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> contactId = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ContactNotesCompanion(
            id: id,
            contactId: contactId,
            body: body,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String contactId,
            required String body,
            required DateTime createdAt,
          }) =>
              ContactNotesCompanion.insert(
            id: id,
            contactId: contactId,
            body: body,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ContactNotesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({contactId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (contactId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactId,
                    referencedTable:
                        $$ContactNotesTableReferences._contactIdTable(db),
                    referencedColumn:
                        $$ContactNotesTableReferences._contactIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ContactNotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContactNotesTable,
    ContactNote,
    $$ContactNotesTableFilterComposer,
    $$ContactNotesTableOrderingComposer,
    $$ContactNotesTableAnnotationComposer,
    $$ContactNotesTableCreateCompanionBuilder,
    $$ContactNotesTableUpdateCompanionBuilder,
    (ContactNote, $$ContactNotesTableReferences),
    ContactNote,
    PrefetchHooks Function({bool contactId})>;
typedef $$ScanDraftsTableCreateCompanionBuilder = ScanDraftsCompanion Function({
  required String id,
  required String parseResultJson,
  Value<String?> imageFrontPath,
  Value<String?> imageBackPath,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ScanDraftsTableUpdateCompanionBuilder = ScanDraftsCompanion Function({
  Value<String> id,
  Value<String> parseResultJson,
  Value<String?> imageFrontPath,
  Value<String?> imageBackPath,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ScanDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $ScanDraftsTable> {
  $$ScanDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parseResultJson => $composableBuilder(
      column: $table.parseResultJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageFrontPath => $composableBuilder(
      column: $table.imageFrontPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageBackPath => $composableBuilder(
      column: $table.imageBackPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ScanDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanDraftsTable> {
  $$ScanDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parseResultJson => $composableBuilder(
      column: $table.parseResultJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageFrontPath => $composableBuilder(
      column: $table.imageFrontPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageBackPath => $composableBuilder(
      column: $table.imageBackPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ScanDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanDraftsTable> {
  $$ScanDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parseResultJson => $composableBuilder(
      column: $table.parseResultJson, builder: (column) => column);

  GeneratedColumn<String> get imageFrontPath => $composableBuilder(
      column: $table.imageFrontPath, builder: (column) => column);

  GeneratedColumn<String> get imageBackPath => $composableBuilder(
      column: $table.imageBackPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ScanDraftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScanDraftsTable,
    ScanDraft,
    $$ScanDraftsTableFilterComposer,
    $$ScanDraftsTableOrderingComposer,
    $$ScanDraftsTableAnnotationComposer,
    $$ScanDraftsTableCreateCompanionBuilder,
    $$ScanDraftsTableUpdateCompanionBuilder,
    (ScanDraft, BaseReferences<_$AppDatabase, $ScanDraftsTable, ScanDraft>),
    ScanDraft,
    PrefetchHooks Function()> {
  $$ScanDraftsTableTableManager(_$AppDatabase db, $ScanDraftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> parseResultJson = const Value.absent(),
            Value<String?> imageFrontPath = const Value.absent(),
            Value<String?> imageBackPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScanDraftsCompanion(
            id: id,
            parseResultJson: parseResultJson,
            imageFrontPath: imageFrontPath,
            imageBackPath: imageBackPath,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String parseResultJson,
            Value<String?> imageFrontPath = const Value.absent(),
            Value<String?> imageBackPath = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ScanDraftsCompanion.insert(
            id: id,
            parseResultJson: parseResultJson,
            imageFrontPath: imageFrontPath,
            imageBackPath: imageBackPath,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScanDraftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScanDraftsTable,
    ScanDraft,
    $$ScanDraftsTableFilterComposer,
    $$ScanDraftsTableOrderingComposer,
    $$ScanDraftsTableAnnotationComposer,
    $$ScanDraftsTableCreateCompanionBuilder,
    $$ScanDraftsTableUpdateCompanionBuilder,
    (ScanDraft, BaseReferences<_$AppDatabase, $ScanDraftsTable, ScanDraft>),
    ScanDraft,
    PrefetchHooks Function()>;
typedef $$ParserCorrectionsTableCreateCompanionBuilder
    = ParserCorrectionsCompanion Function({
  Value<int> id,
  required String contactId,
  required String fieldName,
  required String originalOcr,
  required String originalParsed,
  required String correctedValue,
  required String fieldType,
  required DateTime createdAt,
});
typedef $$ParserCorrectionsTableUpdateCompanionBuilder
    = ParserCorrectionsCompanion Function({
  Value<int> id,
  Value<String> contactId,
  Value<String> fieldName,
  Value<String> originalOcr,
  Value<String> originalParsed,
  Value<String> correctedValue,
  Value<String> fieldType,
  Value<DateTime> createdAt,
});

final class $$ParserCorrectionsTableReferences extends BaseReferences<
    _$AppDatabase, $ParserCorrectionsTable, ParserCorrection> {
  $$ParserCorrectionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactIdTable(_$AppDatabase db) =>
      db.contacts.createAlias(
          $_aliasNameGenerator(db.parserCorrections.contactId, db.contacts.id));

  $$ContactsTableProcessedTableManager get contactId {
    final $_column = $_itemColumn<String>('contact_id')!;

    final manager = $$ContactsTableTableManager($_db, $_db.contacts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ParserCorrectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ParserCorrectionsTable> {
  $$ParserCorrectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldName => $composableBuilder(
      column: $table.fieldName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalOcr => $composableBuilder(
      column: $table.originalOcr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalParsed => $composableBuilder(
      column: $table.originalParsed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctedValue => $composableBuilder(
      column: $table.correctedValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldType => $composableBuilder(
      column: $table.fieldType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableFilterComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ParserCorrectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParserCorrectionsTable> {
  $$ParserCorrectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldName => $composableBuilder(
      column: $table.fieldName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalOcr => $composableBuilder(
      column: $table.originalOcr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalParsed => $composableBuilder(
      column: $table.originalParsed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctedValue => $composableBuilder(
      column: $table.correctedValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldType => $composableBuilder(
      column: $table.fieldType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableOrderingComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ParserCorrectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParserCorrectionsTable> {
  $$ParserCorrectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fieldName =>
      $composableBuilder(column: $table.fieldName, builder: (column) => column);

  GeneratedColumn<String> get originalOcr => $composableBuilder(
      column: $table.originalOcr, builder: (column) => column);

  GeneratedColumn<String> get originalParsed => $composableBuilder(
      column: $table.originalParsed, builder: (column) => column);

  GeneratedColumn<String> get correctedValue => $composableBuilder(
      column: $table.correctedValue, builder: (column) => column);

  GeneratedColumn<String> get fieldType =>
      $composableBuilder(column: $table.fieldType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableAnnotationComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ParserCorrectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ParserCorrectionsTable,
    ParserCorrection,
    $$ParserCorrectionsTableFilterComposer,
    $$ParserCorrectionsTableOrderingComposer,
    $$ParserCorrectionsTableAnnotationComposer,
    $$ParserCorrectionsTableCreateCompanionBuilder,
    $$ParserCorrectionsTableUpdateCompanionBuilder,
    (ParserCorrection, $$ParserCorrectionsTableReferences),
    ParserCorrection,
    PrefetchHooks Function({bool contactId})> {
  $$ParserCorrectionsTableTableManager(
      _$AppDatabase db, $ParserCorrectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParserCorrectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParserCorrectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParserCorrectionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> contactId = const Value.absent(),
            Value<String> fieldName = const Value.absent(),
            Value<String> originalOcr = const Value.absent(),
            Value<String> originalParsed = const Value.absent(),
            Value<String> correctedValue = const Value.absent(),
            Value<String> fieldType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ParserCorrectionsCompanion(
            id: id,
            contactId: contactId,
            fieldName: fieldName,
            originalOcr: originalOcr,
            originalParsed: originalParsed,
            correctedValue: correctedValue,
            fieldType: fieldType,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String contactId,
            required String fieldName,
            required String originalOcr,
            required String originalParsed,
            required String correctedValue,
            required String fieldType,
            required DateTime createdAt,
          }) =>
              ParserCorrectionsCompanion.insert(
            id: id,
            contactId: contactId,
            fieldName: fieldName,
            originalOcr: originalOcr,
            originalParsed: originalParsed,
            correctedValue: correctedValue,
            fieldType: fieldType,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ParserCorrectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({contactId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (contactId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactId,
                    referencedTable:
                        $$ParserCorrectionsTableReferences._contactIdTable(db),
                    referencedColumn: $$ParserCorrectionsTableReferences
                        ._contactIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ParserCorrectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ParserCorrectionsTable,
    ParserCorrection,
    $$ParserCorrectionsTableFilterComposer,
    $$ParserCorrectionsTableOrderingComposer,
    $$ParserCorrectionsTableAnnotationComposer,
    $$ParserCorrectionsTableCreateCompanionBuilder,
    $$ParserCorrectionsTableUpdateCompanionBuilder,
    (ParserCorrection, $$ParserCorrectionsTableReferences),
    ParserCorrection,
    PrefetchHooks Function({bool contactId})>;
typedef $$ContactFtsTableCreateCompanionBuilder = ContactFtsCompanion Function({
  required String contactId,
  required String name,
  required String company,
  required String designation,
  required String email,
  required String phone,
  Value<int> rowid,
});
typedef $$ContactFtsTableUpdateCompanionBuilder = ContactFtsCompanion Function({
  Value<String> contactId,
  Value<String> name,
  Value<String> company,
  Value<String> designation,
  Value<String> email,
  Value<String> phone,
  Value<int> rowid,
});

class $$ContactFtsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactFtsTable> {
  $$ContactFtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get contactId => $composableBuilder(
      column: $table.contactId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get company => $composableBuilder(
      column: $table.company, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));
}

class $$ContactFtsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactFtsTable> {
  $$ContactFtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get contactId => $composableBuilder(
      column: $table.contactId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get company => $composableBuilder(
      column: $table.company, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));
}

class $$ContactFtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactFtsTable> {
  $$ContactFtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);
}

class $$ContactFtsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactFtsTable,
    ContactFt,
    $$ContactFtsTableFilterComposer,
    $$ContactFtsTableOrderingComposer,
    $$ContactFtsTableAnnotationComposer,
    $$ContactFtsTableCreateCompanionBuilder,
    $$ContactFtsTableUpdateCompanionBuilder,
    (ContactFt, BaseReferences<_$AppDatabase, $ContactFtsTable, ContactFt>),
    ContactFt,
    PrefetchHooks Function()> {
  $$ContactFtsTableTableManager(_$AppDatabase db, $ContactFtsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactFtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactFtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactFtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> contactId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> company = const Value.absent(),
            Value<String> designation = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactFtsCompanion(
            contactId: contactId,
            name: name,
            company: company,
            designation: designation,
            email: email,
            phone: phone,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String contactId,
            required String name,
            required String company,
            required String designation,
            required String email,
            required String phone,
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactFtsCompanion.insert(
            contactId: contactId,
            name: name,
            company: company,
            designation: designation,
            email: email,
            phone: phone,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContactFtsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContactFtsTable,
    ContactFt,
    $$ContactFtsTableFilterComposer,
    $$ContactFtsTableOrderingComposer,
    $$ContactFtsTableAnnotationComposer,
    $$ContactFtsTableCreateCompanionBuilder,
    $$ContactFtsTableUpdateCompanionBuilder,
    (ContactFt, BaseReferences<_$AppDatabase, $ContactFtsTable, ContactFt>),
    ContactFt,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$ContactNotesTableTableManager get contactNotes =>
      $$ContactNotesTableTableManager(_db, _db.contactNotes);
  $$ScanDraftsTableTableManager get scanDrafts =>
      $$ScanDraftsTableTableManager(_db, _db.scanDrafts);
  $$ParserCorrectionsTableTableManager get parserCorrections =>
      $$ParserCorrectionsTableTableManager(_db, _db.parserCorrections);
  $$ContactFtsTableTableManager get contactFts =>
      $$ContactFtsTableTableManager(_db, _db.contactFts);
}
