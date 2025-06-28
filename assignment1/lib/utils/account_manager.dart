import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountManager {
  static const _accountKey = 'account_info';
  static const _loginStatusKey = 'login_status';
  static const _currentUserKey = 'current_user';

  // Save account information
  static Future<void> saveAccount(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_accountKey);
    Map<String, dynamic> accounts = {};
    
    if (data != null) {
      accounts = jsonDecode(data) as Map<String, dynamic>;
    }
    
    accounts[username] = password;
    prefs.setString(_accountKey, jsonEncode(accounts));
  }

  // Check if account exists
  static Future<bool> accountExists(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_accountKey);
    if (data == null) return false;
    final accounts = jsonDecode(data) as Map<String, dynamic>;
    return accounts.containsKey(username);
  }

  // Validate account credentials
  static Future<bool> validateAccount(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_accountKey);
    if (data == null) return false;
    final accounts = jsonDecode(data) as Map<String, dynamic>;
    return accounts[username] == password;
  }

  // Set login status
  static Future<void> setLoginStatus(bool isLoggedIn, {String? username}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginStatusKey, isLoggedIn);
    
    if (isLoggedIn && username != null) {
      await prefs.setString(_currentUserKey, username);
    } else if (!isLoggedIn) {
      await prefs.remove(_currentUserKey);
    }
  }

  // Get login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginStatusKey) ?? false;
  }

  // Get current logged in user
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Sign out user
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginStatusKey, false);
    await prefs.remove(_currentUserKey);
  }

  // Clear all account data (for complete logout)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accountKey);
    await prefs.remove(_loginStatusKey);
    await prefs.remove(_currentUserKey);
  }
}
