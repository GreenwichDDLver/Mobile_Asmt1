import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountManager {
  static const _accountKey = 'account_info';

  static Future<void> saveAccount(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> account = {username: password};
    prefs.setString(_accountKey, jsonEncode(account));
  }

  static Future<bool> accountExists(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_accountKey);
    if (data == null) return false;
    final accounts = jsonDecode(data) as Map<String, dynamic>;
    return accounts.containsKey(username);
  }

  static Future<bool> validateAccount(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_accountKey);
    if (data == null) return false;
    final accounts = jsonDecode(data) as Map<String, dynamic>;
    return accounts[username] == password;
  }
}
