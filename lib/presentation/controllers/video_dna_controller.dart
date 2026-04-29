// lib/presentation/controllers/video_dna_controller.dart
// Riverpod state management for Video DNA analyser.
// Calls POST /api/v1/video-dna/analyse on your Fastify backend.

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// ── Result model ──────────────────────────────────────────────────────────────
class VideoDnaResult {
  // Video metadata
  final String videoId;
  final String videoTitle;
  final String channelName;
  final String publishedAt;
  final String duration;
  final String? thumbnailUrl;

  // Raw stats
  final String viewCount;
  final String likeCount;
  final String commentCount;
  final double engagementRate;

  // ARIA scores (0–100)
  final int overallScore;
  final String scoreVerdict;    // "Strong Performer" / "Needs Work" / "Underperforming"
  final String scoreSummary;

  final int hookScore;
  final String hookAnalysis;
  final String? improvedHook;

  final int titleScore;
  final String titleAnalysis;
  final String? betterTitle;

  final int benchmarkScore;
  final String benchmarkAnalysis;
  final List<String> benchmarkStats;

  // ARIA intelligence
  final String ariaInsight;
  final List<String> actionItems;

  // Next video suggestion
  final String nextVideoSuggestion;
  final String nextVideoReason;

  const VideoDnaResult({
    required this.videoId,
    required this.videoTitle,
    required this.channelName,
    required this.publishedAt,
    required this.duration,
    this.thumbnailUrl,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.engagementRate,
    required this.overallScore,
    required this.scoreVerdict,
    required this.scoreSummary,
    required this.hookScore,
    required this.hookAnalysis,
    this.improvedHook,
    required this.titleScore,
    required this.titleAnalysis,
    this.betterTitle,
    required this.benchmarkScore,
    required this.benchmarkAnalysis,
    required this.benchmarkStats,
    required this.ariaInsight,
    required this.actionItems,
    required this.nextVideoSuggestion,
    required this.nextVideoReason,
  });

  factory VideoDnaResult.fromMap(Map<String, dynamic> map) {
    return VideoDnaResult(
      videoId: map['videoId'] ?? '',
      videoTitle: map['videoTitle'] ?? 'Unknown Video',
      channelName: map['channelName'] ?? '',
      publishedAt: map['publishedAt'] ?? '',
      duration: map['duration'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      viewCount: map['viewCount'] ?? '0',
      likeCount: map['likeCount'] ?? '0',
      commentCount: map['commentCount'] ?? '0',
      engagementRate: (map['engagementRate'] as num?)?.toDouble() ?? 0.0,
      overallScore: (map['overallScore'] as num?)?.toInt() ?? 0,
      scoreVerdict: map['scoreVerdict'] ?? 'Analysed',
      scoreSummary: map['scoreSummary'] ?? '',
      hookScore: (map['hookScore'] as num?)?.toInt() ?? 0,
      hookAnalysis: map['hookAnalysis'] ?? '',
      improvedHook: map['improvedHook'],
      titleScore: (map['titleScore'] as num?)?.toInt() ?? 0,
      titleAnalysis: map['titleAnalysis'] ?? '',
      betterTitle: map['betterTitle'],
      benchmarkScore: (map['benchmarkScore'] as num?)?.toInt() ?? 0,
      benchmarkAnalysis: map['benchmarkAnalysis'] ?? '',
      benchmarkStats: List<String>.from(map['benchmarkStats'] ?? []),
      ariaInsight: map['ariaInsight'] ?? '',
      actionItems: List<String>.from(map['actionItems'] ?? []),
      nextVideoSuggestion: map['nextVideoSuggestion'] ?? '',
      nextVideoReason: map['nextVideoReason'] ?? '',
    );
  }
}

// ── State ──────────────────────────────────────────────────────────────────────
class VideoDnaState {
  final bool isLoading;
  final String? error;
  final VideoDnaResult? result;

  const VideoDnaState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  VideoDnaState copyWith({
    bool? isLoading,
    String? error,
    VideoDnaResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return VideoDnaState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      result: clearResult ? null : result ?? this.result,
    );
  }
}

// ── Controller ─────────────────────────────────────────────────────────────────
class VideoDnaController extends StateNotifier<VideoDnaState> {
  VideoDnaController() : super(const VideoDnaState());

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000', // Android emulator
  );

  // ── Validate YouTube URL and extract video ID ────────────────────────────
  String? _extractVideoId(String url) {
    // Handles:
    // https://www.youtube.com/watch?v=VIDEO_ID
    // https://youtu.be/VIDEO_ID
    // https://www.youtube.com/shorts/VIDEO_ID
    // https://m.youtube.com/watch?v=VIDEO_ID
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) return match.group(1);
    }
    return null;
  }

  // ── Analyse a video ───────────────────────────────────────────────────────
  Future<void> analyseVideo(String url) async {
    // Validate URL first
    final videoId = _extractVideoId(url);
    if (videoId == null) {
      state = state.copyWith(
        error: 'That doesn\'t look like a valid YouTube link. Try pasting the full URL.',
        clearResult: true,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true, clearResult: true);

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) throw Exception('Please log in again.');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/video-dna/analyse'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'url': url, 'videoId': videoId}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Analysis took too long. Please try again.'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = VideoDnaResult.fromMap(data['data'] as Map<String, dynamic>);
        state = state.copyWith(isLoading: false, result: result);
      } else if (response.statusCode == 404) {
        throw Exception('Video not found or is private.');
      } else if (response.statusCode == 403) {
        throw Exception('Video DNA is a Pro feature. Upgrade to access full analysis.');
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Analysis failed. Please try again.');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
        clearResult: true,
      );
    }
  }

  // ── Clear state ────────────────────────────────────────────────────────────
  void clear() {
    state = const VideoDnaState();
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────
final videoDnaProvider =
    StateNotifierProvider<VideoDnaController, VideoDnaState>(
  (_) => VideoDnaController(),
);
