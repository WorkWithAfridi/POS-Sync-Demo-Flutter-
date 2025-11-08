import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  SharedPreferences? _prefs;

  /// Initializes SharedPreferences instance
  Future<LocalStorage> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  /// Sets a String value in SharedPreferences
  Future<bool> setString({required String key, required String value}) async {
    return _prefs?.setString(key, value) ?? Future.value(false);
  }

  /// Gets a String value from SharedPreferences
  String? getString({required String key}) {
    return _prefs?.getString(key);
  }

  /// Sets a Boolean value in SharedPreferences
  Future<bool> setBool({required String key, required bool value}) async {
    return _prefs?.setBool(key, value) ?? Future.value(false);
  }

  /// Gets a Boolean value from SharedPreferences
  bool? getBool({required String key}) {
    return _prefs?.getBool(key);
  }

  /// Sets an Integer value in SharedPreferences
  Future<bool> setInt({required String key, required int value}) async {
    return _prefs?.setInt(key, value) ?? Future.value(false);
  }

  /// Gets an Integer value from SharedPreferences
  int? getInt({required String key}) {
    return _prefs?.getInt(key);
  }

  /// Sets a Double value in SharedPreferences
  Future<bool> setDouble({required String key, required double value}) async {
    return _prefs?.setDouble(key, value) ?? Future.value(false);
  }

  /// Gets a Double value from SharedPreferences
  double? getDouble({required String key}) {
    return _prefs?.getDouble(key);
  }

  /// Sets a List of Strings in SharedPreferences
  Future<bool> setStringList({required String key, required List<String> value}) async {
    return _prefs?.setStringList(key, value) ?? Future.value(false);
  }

  /// Gets a List of Strings from SharedPreferences
  List<String>? getStringList({required String key}) {
    return _prefs?.getStringList(key);
  }

  /// Removes a key-value pair from SharedPreferences
  Future<bool> remove({required String key}) async {
    return _prefs?.remove(key) ?? Future.value(false);
  }

  /// Clears all values from SharedPreferences
  Future<bool> clear() async {
    return _prefs?.clear() ?? Future.value(false);
  }
}

LocalStorage localStorageInstance = GetIt.I<LocalStorage>();
