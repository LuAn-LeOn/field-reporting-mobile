import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/login_response_model.dart';

class AuthService {
  /*
   * Android Emulator:
   * 10.0.2.2 = localhost de tu PC
   */
  static const String baseUrl =
      'http://10.0.2.2:8080/api';

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Credenciales incorrectas',
      );
    }

    final json = jsonDecode(response.body);

    return LoginResponseModel.fromJson(json);
  }
}