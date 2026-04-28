// lib/presentation/controllers/aria_session_controller.dart
// ARIA Session State — The thread connecting DISCOVER → STUDIO → LAUNCH
// Creator never has to re-explain themselves across phases

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AriaSession {
  final String? idea;
  final String? script;
  final String? selectedSong;
  final String? platform;
  final String? niche;
  final String? archetype;
  final String? format;
  final String? mood;
  final String? collaboration;
  final String? angle;
  final Map<String, dynamic>? trendContext; // carries full trend data from Discover

  const AriaSession({
    this.idea,
    this.script,
    this.selectedSong,
    this.platform,
    this.niche,
    this.archetype,
    this.format,
    this.mood,
    this.collaboration,
    this.angle,
    this.trendContext,
  });

  AriaSession copyWith({
    String? idea,
    String? script,
    String? selectedSong,
    String? platform,
    String? niche,
    String? archetype,
    String? format,
    String? mood,
    String? collaboration,
    String? angle,
    Map<String, dynamic>? trendContext,
  }) {
    return AriaSession(
      idea: idea ?? this.idea,
      script: script ?? this.script,
      selectedSong: selectedSong ?? this.selectedSong,
      platform: platform ?? this.platform,
      niche: niche ?? this.niche,
      archetype: archetype ?? this.archetype,
      format: format ?? this.format,
      mood: mood ?? this.mood,
      collaboration: collaboration ?? this.collaboration,
      angle: angle ?? this.angle,
      trendContext: trendContext ?? this.trendContext,
    );
  }

  bool get hasIdea => idea != null && idea!.isNotEmpty;
  bool get hasScript => script != null && script!.isNotEmpty;
  bool get hasSong => selectedSong != null && selectedSong!.isNotEmpty;

  void debugPrint() {
    // ignore: avoid_print
    print('[AriaSession] idea=$idea | platform=$platform | niche=$niche | song=$selectedSong');
  }
}

class AriaSessionNotifier extends StateNotifier<AriaSession> {
  AriaSessionNotifier() : super(const AriaSession());

  /// Called from Discover when an idea is locked
  void setIdea(String idea, {Map<String, dynamic>? trendContext}) {
    state = state.copyWith(idea: idea, trendContext: trendContext);
  }

  /// Called from Studio when script is generated
  void setScript(String script) {
    state = state.copyWith(script: script);
  }

  /// Called from Studio BGM tab when song is selected
  void setSong(String songTitle) {
    state = state.copyWith(selectedSong: songTitle);
  }

  /// Set platform from onboarding / user profile
  void setPlatform(String platform) {
    state = state.copyWith(platform: platform);
  }

  /// Set niche from onboarding / user profile
  void setNiche(String niche) {
    state = state.copyWith(niche: niche);
  }

  /// Set detected archetype
  void setArchetype(String archetype) {
    state = state.copyWith(archetype: archetype);
  }

  /// Set video format
  void setFormat(String format) {
    state = state.copyWith(format: format);
  }

  /// Set mood
  void setMood(String mood) {
    state = state.copyWith(mood: mood);
  }

  /// Set collaboration style
  void setCollaboration(String collaboration) {
    state = state.copyWith(collaboration: collaboration);
  }

  /// Set angle / perspective
  void setAngle(String angle) {
    state = state.copyWith(angle: angle);
  }

  /// Full reset — called after a post is launched
  void reset() {
    state = const AriaSession();
  }
}

/// Global provider — import this anywhere in the app
final ariaSessionProvider =
    StateNotifierProvider<AriaSessionNotifier, AriaSession>(
  (ref) => AriaSessionNotifier(),
);
