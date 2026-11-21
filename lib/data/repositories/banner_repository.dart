import '../../firebase/firebase_service.dart';
import '../models/banner_model.dart';

class BannerRepository {
  final FirebaseService _fb = FirebaseService();

  BannerModel get defaultBanner => BannerModel(
    id: 'banner_01',
    title: 'Delicious Lunch Just a Click Away!',
    imageUrl: 'assets/images/video_banner.png',
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    isActive: true,
  );

  Stream<BannerModel> getActiveBannerStream() {
    return _fb.bannersRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return defaultBanner;
      if (data is Map) {
        for (final entry in data.entries) {
          if (entry.value is Map) {
            final banner = BannerModel.fromMap(entry.value as Map, entry.key.toString());
            if (banner.isActive) return banner;
          }
        }
      }
      return defaultBanner;
    });
  }
}

