import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {

  static const _cloudSyncKey =
      'cloud_sync_enabled';

  // ============================================
  // GET CLOUD SYNC STATUS
  // ============================================

  Future<bool> isCloudSyncEnabled() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(_cloudSyncKey)
        ?? false;
  }

  // ============================================
  // SET CLOUD SYNC STATUS
  // ============================================

  Future<void> setCloudSyncEnabled(
      bool value) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _cloudSyncKey,
      value,
    );
  }
}