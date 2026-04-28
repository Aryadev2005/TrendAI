import '../models/song_model.dart';
import '../services/api_service.dart';

class SongRepository {
  Future<List<SongModel>> fetchTopSongs({
    required String niche,
    String? platform,
    String? followerRange,
  }) async {
    try {
      final data = await ApiService.getTopSongs(
        niche: niche,
        platform: platform ?? 'Instagram',
        followerRange: followerRange ?? '10K-50K',
      );
      return (data as List)
        .map((item) => SongModel.fromMap(item as Map<String, dynamic>))
        .toList();
    } catch (_) {
      return _mockSongs(niche);
    }
  }

  Future<List<SongModel>> fetchByBadge(String badge) async {
    final all = await fetchTopSongs(niche: 'general');
    if (badge == 'All') return all;
    return all.where((s) => s.badge == badge).toList();
  }

  List<SongModel> _mockSongs(String niche) {
    return [
      const SongModel(
        id: '1',
        title: 'Kesariya',
        artist: 'Arijit Singh',
        genre: 'Bollywood Romance',
        useCount: '3.2M uses',
        growthPercent: '+240%',
        badge: 'HOT',
        platform: 'Instagram Reels',
        aiTip: 'Use the 15-sec drop at 0:42 — Reels with this timestamp get 2x saves',
        bpm: 94,
        durationSecs: 30,
      ),
      const SongModel(
        id: '2',
        title: 'Pasoori',
        artist: 'Ali Sethi & Shae Gill',
        genre: 'Indie Folk',
        useCount: '1.8M uses',
        growthPercent: '+180%',
        badge: 'HOT',
        platform: 'YouTube Shorts',
        aiTip: 'Transition videos timed to the beat are driving massive shares right now',
        bpm: 88,
        durationSecs: 30,
      ),
      const SongModel(
        id: '3',
        title: 'Besharam Rang',
        artist: 'Vishal–Sheykhar',
        genre: 'Bollywood Item',
        useCount: '920K uses',
        growthPercent: '+95%',
        badge: 'RISING',
        platform: 'Instagram Reels',
        aiTip: 'Fashion try-ons with bold colour pops matching the track aesthetic are trending',
        bpm: 112,
        durationSecs: 30,
      ),
      const SongModel(
        id: '4',
        title: 'Rasiya',
        artist: 'Pritam',
        genre: 'Ambient Bollywood',
        useCount: '450K uses',
        growthPercent: '+320%',
        badge: 'RISING',
        platform: 'Instagram Reels',
        aiTip: 'Use for slow-motion travel or GRWM — aesthetics with this track get 3x reach',
        bpm: 72,
        durationSecs: 30,
      ),
      const SongModel(
        id: '5',
        title: 'Jhoome Jo Pathaan',
        artist: 'Arijit Singh & Sukriti Kakar',
        genre: 'Bollywood Dance',
        useCount: '210K uses',
        growthPercent: '+500%',
        badge: 'NEW',
        platform: 'YouTube Shorts',
        aiTip: 'Day-in-my-life vlogs with this as background music are spiking — post before the wave peaks',
        bpm: 128,
        durationSecs: 30,
      ),
      const SongModel(
        id: '6',
        title: 'Tum Kya Mile',
        artist: 'Arijit Singh',
        genre: 'Romantic Indie',
        useCount: '670K uses',
        growthPercent: '+140%',
        badge: 'RISING',
        platform: 'Instagram Reels',
        aiTip: 'Couple content and wedding prep Reels with this track are going viral in Tier-2 cities',
        bpm: 84,
        durationSecs: 30,
      ),
      const SongModel(
        id: '7',
        title: 'Haul Suno',
        artist: 'Seedhe Maut',
        genre: 'Desi Hip-Hop',
        useCount: '380K uses',
        growthPercent: '+210%',
        badge: 'NEW',
        platform: 'Instagram Reels',
        aiTip: 'Budget haul and thrift-flip content using this track is outperforming paid ads',
        bpm: 140,
        durationSecs: 30,
      ),
    ];
  }
}
