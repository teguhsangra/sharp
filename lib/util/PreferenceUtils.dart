import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils{

  static void saveToPrefs(String key, String value)async{
    final pref = await SharedPreferences.getInstance();
    await pref.setString(key, value);
  }

}