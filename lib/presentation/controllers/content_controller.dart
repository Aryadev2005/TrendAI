import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/content_model.dart';
import '../../data/repositories/content_repository.dart';

class ContentState {
  final ContentModel? generatedContent;
  final bool isLoading;
  final String? error;

  const ContentState({
    this.generatedContent,
    this.isLoading = false,
    this.error,
  });

  ContentState copyWith({
    ContentModel? generatedContent,
    bool? isLoading,
    String? error,
  }) {
    return ContentState(
      generatedContent: generatedContent ?? this.generatedContent,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ContentController extends StateNotifier<ContentState> {
  final ContentRepository _repo;
  ContentController(this._repo) : super(const ContentState());

  Future<void> generateContent({
    required String trendTitle,
    required String platform,
    String niche = 'fashion',
    String? songTitle,
    String tone = 'casual',
    String language = 'hinglish',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final content = await _repo.generateContent(
        trendTitle: trendTitle,
        platform: platform,
        niche: niche,
        songTitle: songTitle,
        tone: tone,
        language: language,
      );
      state = state.copyWith(generatedContent: content, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearContent() {
    state = const ContentState();
  }
}

final contentRepositoryProvider = Provider((ref) => ContentRepository());

final contentProvider =
    StateNotifierProvider<ContentController, ContentState>(
  (ref) => ContentController(ref.read(contentRepositoryProvider)),
);
