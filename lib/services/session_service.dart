import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_response_model.dart';
import '../models/user_model.dart';

class SessionService {
  static const _tokenKey = 'auth_token';

  static const _userKey = 'auth_user';

  Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );

    await prefs.setString(
      _userKey,
      jsonEncode(
        user.toJson(),
      ),
    );
  }

  Future<String?> getToken() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    return prefs.getString(
      _tokenKey,
    );
  }

  Future<UserModel?> getUser() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    final userJson =
    prefs.getString(
      _userKey,
    );

    if (userJson == null) {
      return null;
    }

    return UserModel.fromJson(
      jsonDecode(userJson),
    );
  }

  Future<LoginResponseModel?>
  getSession() async {
    final token =
    await getToken();

    final user =
    await getUser();

    if (token == null ||
        user == null) {
      return null;
    }

    return LoginResponseModel(
      token: token,
      user: user,
    );
  }

  Future<void> clearSession() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.remove(
      _tokenKey,
    );

    await prefs.remove(
      _userKey,
    );
  }

  Future<bool> isLoggedIn() async {
    final token =
    await getToken();

    return token != null &&
        token.isNotEmpty;
  }
}