class TimingSlot {
  final String day;
  final String time;
  final int score;
  final String reason;

  const TimingSlot({
    required this.day,
    required this.time,
    required this.score,
    required this.reason,
  });

  factory TimingSlot.fromJson(Map<String, dynamic> j) => TimingSlot(
    day:    j['day']    ?? '',
    time:   j['time']  ?? '',
    score:  j['score'] ?? 0,
    reason: j['reason'] ?? '',
  );
}

class TimingIntelligence {
  final List<TimingSlot> bestSlots;
  final String weeklyPattern;
  final String platformInsight;
  final List<String> avoidWindows;
  final String nextBestSlot;
  final int nextBestSlotHoursAway;
  final String ariaReason;
  final bool fromCache;

  const TimingIntelligence({
    required this.bestSlots,
    required this.weeklyPattern,
    required this.platformInsight,
    required this.avoidWindows,
    required this.nextBestSlot,
    required this.nextBestSlotHoursAway,
    required this.ariaReason,
    this.fromCache = false,
  });

  factory TimingIntelligence.fromJson(Map<String, dynamic> j) => TimingIntelligence(
    bestSlots:              (j['bestSlots'] as List? ?? [])
        .map((s) => TimingSlot.fromJson(s)).toList(),
    weeklyPattern:          j['weeklyPattern']          ?? '',
    platformInsight:        j['platformInsight']        ?? '',
    avoidWindows:           List<String>.from(j['avoidWindows'] ?? []),
    nextBestSlot:           j['nextBestSlot']           ?? '',
    nextBestSlotHoursAway:  j['nextBestSlotHoursAway']  ?? 0,
    ariaReason:             j['ariaReason']             ?? '',
    fromCache:              j['fromCache']              ?? false,
  );
}

class HashtagSet {
  final List<String> mega;
  final List<String> mid;
  final List<String> niche;

  const HashtagSet({
    required this.mega,
    required this.mid,
    required this.niche,
  });

  List<String> get all => [...mega, ...mid, ...niche];

  factory HashtagSet.fromJson(Map<String, dynamic> j) => HashtagSet(
    mega:  List<String>.from(j['mega']  ?? []),
    mid:   List<String>.from(j['mid']   ?? []),
    niche: List<String>.from(j['niche'] ?? []),
  );
}

class PostingPackage {
  final String caption;
  final String firstComment;
  final HashtagSet hashtags;
  final String altText;
  final String storyCopy;
  final String youtubeDescription;
  final String thumbnailText;
  final String ariaPostingTip;
  final String estimatedReach;
  final String bestDayTime;

  const PostingPackage({
    required this.caption,
    required this.firstComment,
    required this.hashtags,
    required this.altText,
    required this.storyCopy,
    required this.youtubeDescription,
    required this.thumbnailText,
    required this.ariaPostingTip,
    required this.estimatedReach,
    required this.bestDayTime,
  });

  factory PostingPackage.fromJson(Map<String, dynamic> j) => PostingPackage(
    caption:             j['caption']            ?? '',
    firstComment:        j['firstComment']       ?? '',
    hashtags:            HashtagSet.fromJson(j['hashtags'] as Map<String, dynamic>? ?? {}),
    altText:             j['altText']            ?? '',
    storyCopy:           j['storyCopy']          ?? '',
    youtubeDescription:  j['youtubeDescription'] ?? '',
    thumbnailText:       j['thumbnailText']      ?? '',
    ariaPostingTip:      j['ariaPostingTip']     ?? '',
    estimatedReach:      j['estimatedReach']     ?? '',
    bestDayTime:         j['bestDayTime']        ?? '',
  );
}

class BrandOpportunity {
  final String brand;
  final String category;
  final int fitScore;
  final String timing;
  final String estimatedDeal;

  const BrandOpportunity({
    required this.brand,
    required this.category,
    required this.fitScore,
    required this.timing,
    required this.estimatedDeal,
  });

  factory BrandOpportunity.fromJson(Map<String, dynamic> j) => BrandOpportunity(
    brand:         j['brand']         ?? '',
    category:      j['category']      ?? '',
    fitScore:      j['fitScore']      ?? 0,
    timing:        j['timing']        ?? '',
    estimatedDeal: j['estimatedDeal'] ?? '',
  );
}

class PitchTemplate {
  final String subject;
  final String body;
  final String whatsappVersion;

  const PitchTemplate({
    required this.subject,
    required this.body,
    required this.whatsappVersion,
  });

  factory PitchTemplate.fromJson(Map<String, dynamic> j) => PitchTemplate(
    subject:          j['subject']          ?? '',
    body:             j['body']             ?? '',
    whatsappVersion:  j['whatsappVersion']  ?? '',
  );
}

class BrandAlert {
  final List<BrandOpportunity> brandOpportunities;
  final PitchTemplate pitchTemplate;
  final String ariaAdvice;

  const BrandAlert({
    required this.brandOpportunities,
    required this.pitchTemplate,
    required this.ariaAdvice,
  });

  factory BrandAlert.fromJson(Map<String, dynamic> j) => BrandAlert(
    brandOpportunities: (j['brandOpportunities'] as List? ?? [])
        .map((b) => BrandOpportunity.fromJson(b)).toList(),
    pitchTemplate:      PitchTemplate.fromJson(j['pitchTemplate'] as Map<String, dynamic>? ?? {}),
    ariaAdvice:         j['ariaAdvice'] ?? '',
  );
}
