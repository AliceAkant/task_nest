import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_factory.dart';

extension SharedPreferencesExtension on SharedPreferences {
  Future<bool> clearExcept(List<String> excludedKeys) async {
    var sp = await SharedPreferencesFactory.get();
    var tasksList = <Future>[];
    for (String key in sp.getKeys()) {
      if (!excludedKeys.contains(key)) {
        tasksList.add(sp.remove(key));
      }
    }

    await Future.wait(tasksList);

    return true;
  }
}
