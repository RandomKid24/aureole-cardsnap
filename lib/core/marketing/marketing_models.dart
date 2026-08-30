/// `GET /api/auth/scope` — which domain / region the signed-in employee belongs
/// to. No permission gate.
class MarketingScope {
  final String? role;
  final int? domainId;
  final int? regionId;
  final List<int> regionIds;
  final int? employeeId;
  final bool isDomainCoordinator;
  final bool isRegionCoordinator;

  const MarketingScope({
    this.role,
    this.domainId,
    this.regionId,
    this.regionIds = const [],
    this.employeeId,
    this.isDomainCoordinator = false,
    this.isRegionCoordinator = false,
  });

  factory MarketingScope.fromJson(Map<String, dynamic> j) {
    int? asInt(dynamic v) => v is int ? v : (v is num ? v.toInt() : null);
    return MarketingScope(
      role: j['role'] as String?,
      domainId: asInt(j['domain_id']),
      regionId: asInt(j['region_id']),
      regionIds: (j['region_ids'] as List?)?.map(asInt).whereType<int>().toList() ?? const [],
      employeeId: asInt(j['employee_id']),
      isDomainCoordinator: j['is_domain_coordinator'] == true,
      isRegionCoordinator: j['is_region_coordinator'] == true,
    );
  }
}

/// `GET /api/exhibitions/active` — trimmed shape by design (no budget / vendor /
/// payment fields).
class Exhibition {
  final int id;
  final String name;
  final String? location;
  final String? startDate;
  final String? endDate;
  final int? domainId;

  const Exhibition({
    required this.id,
    required this.name,
    this.location,
    this.startDate,
    this.endDate,
    this.domainId,
  });

  factory Exhibition.fromJson(Map<String, dynamic> j) => Exhibition(
        id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
        name: (j['name'] as String?) ?? 'Exhibition',
        location: j['location'] as String?,
        startDate: j['start_date'] as String?,
        endDate: j['end_date'] as String?,
        domainId: j['domain_id'] is int ? j['domain_id'] as int : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'start_date': startDate,
        'end_date': endDate,
        'domain_id': domainId,
      };

  String get label {
    final loc = (location ?? '').trim();
    return loc.isEmpty ? name : '$name — $loc';
  }

  /// "21 Jan – 24 Jan 2026" style, best-effort from ISO date strings.
  String get dateRange {
    final a = _fmt(startDate), b = _fmt(endDate);
    if (a == null && b == null) return '';
    if (a != null && b != null) return a == b ? a : '$a – $b';
    return a ?? b!;
  }

  /// name + location + dates, for a picker row.
  String get subtitle {
    final parts = <String>[
      if ((location ?? '').trim().isNotEmpty) location!.trim(),
      if (dateRange.isNotEmpty) dateRange,
    ];
    return parts.join('  ·  ');
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String? _fmt(String? iso) {
    if (iso == null) return null;
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  @override
  bool operator ==(Object other) => other is Exhibition && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// What the "save this card" screen needs from the Marketing API.
class MarketingCaptureContext {
  final MarketingScope? scope;
  final List<Exhibition> exhibitions;

  /// Non-null when the exhibitions list couldn't be loaded for a reason worth
  /// telling the user about (e.g. missing `marketing.view_events`).
  final String? exhibitionsError;

  const MarketingCaptureContext({
    this.scope,
    this.exhibitions = const [],
    this.exhibitionsError,
  });

  /// `/api/exhibitions/active` already scopes to the caller's domain(s), so this
  /// is just the list sorted by name for a stable picker.
  List<Exhibition> get activeExhibitions =>
      [...exhibitions]..sort((a, b) => a.name.compareTo(b.name));
}
