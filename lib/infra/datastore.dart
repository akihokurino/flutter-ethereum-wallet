import 'package:shared_preferences/shared_preferences.dart';

class DataStore {
  final _walletPrivateKey = "wallet-private-key";

  static final DataStore _singleton = DataStore._internal();

  factory DataStore() {
    return _singleton;
  }

  DataStore._internal();

  Future<String> getPrivateKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_walletPrivateKey) ?? "";
  }

  Future<void> savePrivateKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_walletPrivateKey, key);
  }
}
