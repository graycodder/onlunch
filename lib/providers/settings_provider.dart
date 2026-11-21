import 'package:flutter/foundation.dart';
import '../models/corporate_lunch_settings.dart';
import '../services/lunch_ordering_service.dart';

class SettingsProvider extends ChangeNotifier {
  CorporateLunchSettings _settings = CorporateLunchSettings();
  bool _isLoading = true;

  CorporateLunchSettings get settings => _settings;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _initStream();
  }

  void _initStream() {
    LunchOrderingService().streamSettings().listen(
      (newSettings) {
        _settings = newSettings;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        debugPrint('SettingsProvider stream error: $err');
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}

