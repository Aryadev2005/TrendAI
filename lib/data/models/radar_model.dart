// lib/data/models/radar_model.dart

class AriaTopPick {
  final String title;
  final String reason;
  final String urgency; // high | medium | low
  final int peakWindowHours;

  const AriaTopPick({
    required this.title,
    required this.reason,
    required this.urgency,
    required this.peakWindowHours,
  });

  factory AriaTopPick.fromJson(Map<String, dynamic> json) => AriaTopPick(
    title:           json['title'] ?? '',
    reason:          json['reason'] ?? '',
    urgency:         json['urgency'] ?? 'medium',
    peakWindowHours: json['peakWindowHours'] ?? 48,
  );
}

class RadarOpportunity {
  final String id;
  final String title;
  final String description;
  final String angle;
  final String badge; // HOT | RISING | NEW
  final int opportunityScore;
  final bool nobodyHasDoneThis;
  final int peakWindowHours;
  final String estimatedViews;
  final String hookSuggestion;
  final String nicheSource;

  const RadarOpportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.angle,
    required this.badge,
    required this.opportunityScore,
    required this.nobodyHasDoneThis,
    required this.peakWindowHours,
    required this.estimatedViews,
    required this.hookSuggestion,
    required this.nicheSource,
  });

  factory RadarOpportunity.fromJson(Map<String, dynamic> json) => RadarOpportunity(
    id:                 json['id'] ?? '',
    title:              json['title'] ?? '',
    description:        json['description'] ?? '',
    angle:              json['angle'] ?? '',
    badge:              json['badge'] ?? 'RISING',
    opportunityScore:   json['opportunityScore'] ?? 0,
    nobodyHasDoneThis:  json['nobodyHasDoneThis'] ?? false,
    peakWindowHours:    json['peakWindowHours'] ?? 48,
    estimatedViews:     json['estimatedViews'] ?? '',
    hookSuggestion:     json['hookSuggestion'] ?? '',
    nicheSource:        json['nicheSource'] ?? '',
  );
}

class CompetitorMove {
  final String description;
  final String engagement;
  final String gap;

  const CompetitorMove({
    required this.description,
    required this.engagement,
    required this.gap,
  });

  factory CompetitorMove.fromJson(Map<String, dynamic> json) => CompetitorMove(
    description: json['description'] ?? '',
    engagement:  json['engagement'] ?? '',
    gap:         json['gap'] ?? '',
  );
}

class FestivalBoost {
  final String name;
  final int daysUntil;
  final int windowDays;
  final bool isUrgent;

  const FestivalBoost({
    required this.name,
    required this.daysUntil,
    required this.windowDays,
    required this.isUrgent,
  });

  factory FestivalBoost.fromJson(Map<String, dynamic> json) => FestivalBoost(
    name:       json['name'] ?? '',
    daysUntil:  json['daysUntil'] ?? 0,
    windowDays: json['windowDays'] ?? 7,
    isUrgent:   json['isUrgent'] ?? false,
  );
}

class RadarIntelligence {
  final AriaTopPick ariaTopPick;
  final List<RadarOpportunity> opportunities;
  final List<CompetitorMove> competitorMoves;
  final List<FestivalBoost> festivalBoosts;
  final bool fromCache;

  const RadarIntelligence({
    required this.ariaTopPick,
    required this.opportunities,
    required this.competitorMoves,
    required this.festivalBoosts,
    required this.fromCache,
  });

  factory RadarIntelligence.fromJson(Map<String, dynamic> json) {
    final intel = json['intelligence'] as Map<String, dynamic>? ?? json;
    return RadarIntelligence(
      ariaTopPick:     AriaTopPick.fromJson(intel['ariaTopPick'] ?? {}),
      opportunities:   (intel['opportunities'] as List? ?? [])
          .map((e) => RadarOpportunity.fromJson(e)).toList(),
      competitorMoves: (intel['competitorMoves'] as List? ?? [])
          .map((e) => CompetitorMove.fromJson(e)).toList(),
      festivalBoosts:  (intel['festivalBoosts'] as List? ?? [])
          .map((e) => FestivalBoost.fromJson(e)).toList(),
      fromCache:       json['fromCache'] ?? false,
    );
  }
}
