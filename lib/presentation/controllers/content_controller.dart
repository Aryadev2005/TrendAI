import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/content_model.dart';

class ContentState {
  final ContentModel? generatedContent;
  final bool isLoading;
  final String? error;

  const ContentState({this.generatedContent, this.isLoading = false, this.error});

  ContentState copyWith({ContentModel? generatedContent, bool? isLoading, String? error}) {
    return ContentState(
      generatedContent: generatedContent ?? this.generatedContent,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ContentController extends StateNotifier<ContentState> {
  ContentController() : super(const ContentState());

  Future<void> generateContent(String trendTitle, String platform) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(seconds: 2));
      // Mock — replace with Claude API call in api_service.dart
      final content = ContentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        trendId: trendTitle,
        hook: 'I spent ₹500 and looked like I spent ₹50,000 — here\'s how',
        caption: 'Quiet luxury isn\'t about price — it\'s about intention. Here are my 3 rules for looking effortlessly elevated on any budget...',
        hashtags: ['#QuietLuxury', '#IndianFashion', '#StyleTips', '#OOTDIndia', '#FashionReels'],
        bestTimeToPost: 'Today · 7:30 PM IST',
        platform: platform,
        generatedAt: DateTime.now(),
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

final contentProvider = StateNotifierProvider<ContentController, ContentState>(
  (ref) => ContentController(),
);