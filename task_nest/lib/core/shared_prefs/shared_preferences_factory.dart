import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesFactory {
  static Future<SharedPreferences> get() async {
    var instance = await SharedPreferences.getInstance();
    return instance;
  }
}
