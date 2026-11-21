import '../../firebase/firebase_service.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  final FirebaseService _fb = FirebaseService();

  SettingsModel get defaultSettings => SettingsModel(
    lunchAvailability: true,
    orderCutoffTime: '11:30 AM',
    supportPhone: '+919995226139',
    minimumOrderAmount: 0.0,
  );

  Stream<SettingsModel> getSettingsStream() {
    return _fb.settingsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return SettingsModel.fromMap(data);
      }
      return defaultSettings;
    });
  }
}

