// lib/presentation/controllers/studio_controller.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _base = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1');

// ─── Script Section Model ─────────────────────────────────────────────────────
class ScriptSection {
  final String id;
  final String label;
  final String duration;
  String content;       // mutable — creator edits this
  final String bRollIdea;
  final String ariaTip;
  bool isEditing;
  String? ariaAdvice;   // set when creator asks ARIA to review this section

  ScriptSection({
    required this.id,
    required this.label,
    required this.duration,
    required this.content,
    required this.bRollIdea,
    required this.ariaTip,
    this.isEditing  = false,
    this.ariaAdvice,
  });

  factory ScriptSection.fromJson(Map<String, dynamic> j) => ScriptSection(
    id:         j['id']         ?? '',
    label:      j['label']      ?? '',
    duration:   j['duration']   ?? '',
    content:    j['content']    ?? '',
    bRollIdea:  j['bRollIdea']  ?? '',
    ariaTip:    j['ariaTip']    ?? '',
  );

  ScriptSection copyWith({String? content, bool? isEditing, String? ariaAdvice}) =>
    ScriptSection(
      id: id, label: label, duration: duration,
      content:    content    ?? this.content,
      bRollIdea:  bRollIdea,
      ariaTip:    ariaTip,
      isEditing:  isEditing  ?? this.isEditing,
      ariaAdvice: ariaAdvice ?? this.ariaAdvice,
    );
}

// ─── BGM Recommendation Model ─────────────────────────────────────────────────
class BGMRecommendation {
  final int rank;
  final String title;
  final String artist;
  final String why;
  final String timestampTip;
  final String source;
  final int viralPotential;
  final String? warning;
  bool isSelected;

  BGMRecommendation({
    required this.rank,
    required this.title,
    required this.artist,
    required this.why,
    required this.timestampTip,
    required this.source,
    required this.viralPotential,
    this.warning,
    this.isSelected = false,
  });

  factory BGMRecommendation.fromJson(Map<String, dynamic> j) => BGMRecommendation(
    rank:           j['rank']           ?? 0,
    title:          j['title']          ?? '',
    artist:         j['artist']         ?? '',
    why:            j['why']            ?? '',
    timestampTip:   j['timestampTip']   ?? '',
    source:         j['source']         ?? '',
    viralPotential: j['viralPotential'] ?? 0,
    warning:        j['warning'] == 'null' ? null : j['warning'],
  );
}

// ─── Video Analysis Model ─────────────────────────────────────────────────────
class VideoFix {
  final String timestamp;
  final String issue;
  final String fix;
  final String priority;

  const VideoFix({
    required this.timestamp,
    required this.issue,
    required this.fix,
    required this.priority,
  });

  factory VideoFix.fromJson(Map<String, dynamic> j) => VideoFix(
    timestamp: j['timestamp'] ?? '',
    issue:     j['issue']     ?? '',
    fix:       j['fix']       ?? '',
    priority:  j['priority']  ?? 'medium',
  );
}

class VideoAnalysis {
  final int overallScore;
  final String grade;
  final String verdict;
  final String topPriorityFix;
  final List<VideoFix> specificFixes;
  final List<String> whatWorked;
  final String estimatedReach;
  final String estimatedReachAfterFixes;
  final Map<String, dynamic> hookAnalysis;
  final Map<String, dynamic> pacingAnalysis;
  final Map<String, dynamic> scriptAnalysis;
  final String analysisType;

  const VideoAnalysis({
    required this.overallScore,
    required this.grade,
    required this.verdict,
    required this.topPriorityFix,
    required this.specificFixes,
    required this.whatWorked,
    required this.estimatedReach,
    required this.estimatedReachAfterFixes,
    required this.hookAnalysis,
    required this.pacingAnalysis,
    required this.scriptAnalysis,
    required this.analysisType,
  });

  factory VideoAnalysis.fromJson(Map<String, dynamic> j) => VideoAnalysis(
    overallScore:             j['overallScore']             ?? 0,
    grade:                    j['grade']                    ?? 'C',
    verdict:                  j['verdict']                  ?? '',
    topPriorityFix:           j['topPriorityFix']           ?? '',
    specificFixes:            (j['specificFixes'] as List?  ?? [])
        .map((f) => VideoFix.fromJson(f)).toList(),
    whatWorked:               List<String>.from(j['whatWorked'] ?? []),
    estimatedReach:           j['estimatedReach']           ?? '',
    estimatedReachAfterFixes: j['estimatedReachAfterFixes'] ?? '',
    hookAnalysis:   j['hookAnalysis']   as Map<String, dynamic>? ?? {},
    pacingAnalysis: j['pacingAnalysis'] as Map<String, dynamic>? ?? {},
    scriptAnalysis: j['scriptAnalysis'] as Map<String, dynamic>? ?? {},
    analysisType:   j['analysisType']   ?? 'deep',
  );
}

// ─── State ────────────────────────────────────────────────────────────────────
enum StudioTab { script, bgm, shots, editing, analysis }

class StudioState {
  final StudioTab activeTab;

  // Script
  final bool   scriptLoading;
  final String hookLine;
  final String hookTip;
  final List<ScriptSection> sections;
  final List<String> shootingTips;
  final String commonMistake;
  final int    viralPotential;
  final String? advisingSection; // section id being advised
  final String? sectionAdvice;

  // BGM
  final bool bgmLoading;
  final String selectedMood;
  final List<BGMRecommendation> bgmRecs;
  final String audioStrategy;
  final String avoidThis;

  // Editing help
  final bool   editingLoading;
  final String selectedTool;
  final String editingProblem;
  final Map<String, dynamic>? editingResult;

  // Video analysis
  final bool   analysisLoading;
  final VideoAnalysis? videoAnalysis;
  final String? analysisError;

  // General
  final bool   isSaving;
  final String? error;

  const StudioState({
    this.activeTab       = StudioTab.script,
    this.scriptLoading   = false,
    this.hookLine        = '',
    this.hookTip         = '',
    this.sections        = const [],
    this.shootingTips    = const [],
    this.commonMistake   = '',
    this.viralPotential  = 0,
    this.advisingSection,
    this.sectionAdvice,
    this.bgmLoading      = false,
    this.selectedMood    = 'informative',
    this.bgmRecs         = const [],
    this.audioStrategy   = '',
    this.avoidThis       = '',
    this.editingLoading  = false,
    this.selectedTool    = 'CapCut',
    this.editingProblem  = '',
    this.editingResult,
    this.analysisLoading = false,
    this.videoAnalysis,
    this.analysisError,
    this.isSaving        = false,
    this.error,
  });

  StudioState copyWith({
    StudioTab? activeTab, bool? scriptLoading, String? hookLine,
    String? hookTip, List<ScriptSection>? sections,
    List<String>? shootingTips, String? commonMistake, int? viralPotential,
    String? advisingSection, String? sectionAdvice,
    bool? bgmLoading, String? selectedMood, List<BGMRecommendation>? bgmRecs,
    String? audioStrategy, String? avoidThis,
    bool? editingLoading, String? selectedTool, String? editingProblem,
    Map<String, dynamic>? editingResult,
    bool? analysisLoading, VideoAnalysis? videoAnalysis, String? analysisError,
    bool? isSaving, String? error,
  }) => StudioState(
    activeTab:       activeTab       ?? this.activeTab,
    scriptLoading:   scriptLoading   ?? this.scriptLoading,
    hookLine:        hookLine        ?? this.hookLine,
    hookTip:         hookTip         ?? this.hookTip,
    sections:        sections        ?? this.sections,
    shootingTips:    shootingTips    ?? this.shootingTips,
    commonMistake:   commonMistake   ?? this.commonMistake,
    viralPotential:  viralPotential  ?? this.viralPotential,
    advisingSection: advisingSection,
    sectionAdvice:   sectionAdvice,
    bgmLoading:      bgmLoading      ?? this.bgmLoading,
    selectedMood:    selectedMood    ?? this.selectedMood,
    bgmRecs:         bgmRecs         ?? this.bgmRecs,
    audioStrategy:   audioStrategy   ?? this.audioStrategy,
    avoidThis:       avoidThis       ?? this.avoidThis,
    editingLoading:  editingLoading  ?? this.editingLoading,
    selectedTool:    selectedTool    ?? this.selectedTool,
    editingProblem:  editingProblem  ?? this.editingProblem,
    editingResult:   editingResult   ?? this.editingResult,
    analysisLoading: analysisLoading ?? this.analysisLoading,
    videoAnalysis:   videoAnalysis   ?? this.videoAnalysis,
    analysisError:   analysisError,
    isSaving:        isSaving        ?? this.isSaving,
    error:           error,
  );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class StudioNotifier extends StateNotifier<StudioState> {
  final String? authToken;
  StudioNotifier({this.authToken}) : super(const StudioState());

  Map<String, String> get _h => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  void setTab(StudioTab tab) => state = state.copyWith(activeTab: tab);
  void setMood(String mood)  => state = state.copyWith(selectedMood: mood);
  void setTool(String tool)  => state = state.copyWith(selectedTool: tool);
  void setProblem(String p)  => state = state.copyWith(editingProblem: p);

  // ── Generate script structure ───────────────────────────────────────────
  Future<void> generateScript({
    required String idea,
    String? platform, String? niche,
    String? format, String? mood,
    String? collaboration, String? angle,
  }) async {
    state = state.copyWith(scriptLoading: true, error: null);
    try {
      final res = await http.post(
        Uri.parse('$_base/studio/script/structure'),
        headers: _h,
        body: jsonEncode({
          'idea': idea, 'platform': platform, 'niche': niche,
          'format': format, 'mood': mood,
          'collaboration': collaboration, 'angle': angle,
        }),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data     = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        final sections = (data['sections'] as List? ?? [])
            .map((s) => ScriptSection.fromJson(s)).toList();

        state = state.copyWith(
          scriptLoading:  false,
          hookLine:       data['hookLine']       ?? '',
          hookTip:        data['hookTip']        ?? '',
          sections:       sections,
          shootingTips:   List<String>.from(data['shootingTips'] ?? []),
          commonMistake:  data['commonMistake']  ?? '',
          viralPotential: data['viralPotential'] ?? 0,
        );
      } else {
        state = state.copyWith(scriptLoading: false, error: 'Script generation failed');
      }
    } catch (e) {
      state = state.copyWith(scriptLoading: false, error: e.toString());
    }
  }

  // ── Creator edits a section ─────────────────────────────────────────────
  void updateSection(String sectionId, String newContent) {
    final updated = state.sections.map((s) {
      if (s.id == sectionId) return s.copyWith(content: newContent);
      return s;
    }).toList();
    state = state.copyWith(sections: updated);
  }

  // ── Ask ARIA to advise on a section ────────────────────────────────────
  Future<void> adviseSection(String sectionId, String idea, String mood) async {
    final section = state.sections.firstWhere((s) => s.id == sectionId);
    state = state.copyWith(advisingSection: sectionId, sectionAdvice: null);

    try {
      final res = await http.post(
        Uri.parse('$_base/studio/script/advise'),
        headers: _h,
        body: jsonEncode({
          'sectionLabel':   section.label,
          'creatorContent': section.content,
          'sectionType':    section.id,
          'idea': idea, 'mood': mood,
        }),
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        // Update section with advice
        final updated = state.sections.map((s) {
          if (s.id == sectionId) {
            return s.copyWith(ariaAdvice: data['suggestion'] ?? '');
          }
          return s;
        }).toList();
        state = state.copyWith(
          sections:        updated,
          advisingSection: null,
          sectionAdvice:   jsonEncode(data),
        );
      } else {
        state = state.copyWith(advisingSection: null);
      }
    } catch (e) {
      state = state.copyWith(advisingSection: null, error: e.toString());
    }
  }

  // ── Apply ARIA's suggestion to section ─────────────────────────────────
  void applySuggestion(String sectionId, String suggestion) {
    final updated = state.sections.map((s) {
      if (s.id == sectionId) return s.copyWith(content: suggestion, ariaAdvice: null);
      return s;
    }).toList();
    state = state.copyWith(sections: updated);
  }

  // ── Dismiss ARIA's advice ───────────────────────────────────────────────
  void dismissAdvice(String sectionId) {
    final updated = state.sections.map((s) {
      if (s.id == sectionId) return s.copyWith(ariaAdvice: null);
      return s;
    }).toList();
    state = state.copyWith(sections: updated);
  }

  // ── Match BGM ──────────────────────────────────────────────────────────
  Future<void> matchBGM(String idea, {String? format}) async {
    state = state.copyWith(bgmLoading: true, error: null);
    try {
      final res = await http.post(
        Uri.parse('$_base/studio/bgm/match'),
        headers: _h,
        body: jsonEncode({'idea': idea, 'mood': state.selectedMood, 'format': format}),
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        final recs = (data['recommendations'] as List? ?? [])
            .map((r) => BGMRecommendation.fromJson(r)).toList();
        state = state.copyWith(
          bgmLoading:    false,
          bgmRecs:       recs,
          audioStrategy: data['audioStrategy'] ?? '',
          avoidThis:     data['avoidThis']     ?? '',
        );
      } else {
        state = state.copyWith(bgmLoading: false, error: 'BGM match failed');
      }
    } catch (e) {
      state = state.copyWith(bgmLoading: false, error: e.toString());
    }
  }

  void selectBGM(int rank) {
    final updated = state.bgmRecs.map((r) =>
      BGMRecommendation(
        rank: r.rank, title: r.title, artist: r.artist, why: r.why,
        timestampTip: r.timestampTip, source: r.source,
        viralPotential: r.viralPotential, warning: r.warning,
        isSelected: r.rank == rank,
      )
    ).toList();
    state = state.copyWith(bgmRecs: updated);
  }

  // ── Get editing help ───────────────────────────────────────────────────
  Future<void> getEditingHelp() async {
    if (state.editingProblem.isEmpty) return;
    state = state.copyWith(editingLoading: true, error: null);
    try {
      final res = await http.post(
        Uri.parse('$_base/studio/editing/help'),
        headers: _h,
        body: jsonEncode({'problem': state.editingProblem, 'tool': state.selectedTool}),
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        state = state.copyWith(editingLoading: false, editingResult: data);
      } else {
        state = state.copyWith(editingLoading: false, error: 'Editing help failed');
      }
    } catch (e) {
      state = state.copyWith(editingLoading: false, error: e.toString());
    }
  }

  // ── Analyse video URL ──────────────────────────────────────────────────
  Future<void> analyseVideoUrl(String url) async {
    state = state.copyWith(analysisLoading: true, analysisError: null);
    try {
      final res = await http.post(
        Uri.parse('$_base/studio/analyse/url'),
        headers: _h,
        body: jsonEncode({'videoUrl': url}),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data     = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        final analysis = VideoAnalysis.fromJson(data);
        state = state.copyWith(analysisLoading: false, videoAnalysis: analysis);
      } else {
        state = state.copyWith(
          analysisLoading: false,
          analysisError: 'Analysis failed — try again',
        );
      }
    } catch (e) {
      state = state.copyWith(analysisLoading: false, analysisError: e.toString());
    }
  }

  void clearAnalysis() => state = state.copyWith(videoAnalysis: null, analysisError: null);
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final studioProvider = StateNotifierProvider<StudioNotifier, StudioState>((ref) {
  // TODO: Wire auth token from ref.watch(authProvider).user?.id once available
  return StudioNotifier(authToken: null);
});
