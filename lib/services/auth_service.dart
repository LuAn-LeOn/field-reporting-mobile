import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/login_response_model.dart';
import '../models/pending_user_model.dart';

class AuthService {
  /*
   * Android Emulator:
   * 10.0.2.2 = localhost de tu PC
   */
  static const String baseUrl = 'http://10.0.2.2:8080/api';

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
        'email': email.trim(),
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Credenciales incorrectas o usuario pendiente de autorización',
      );
    }

    final json = jsonDecode(response.body);

    return LoginResponseModel.fromJson(json);
  }

  Future<String> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'No se pudo registrar el usuario',
      );
    }

    final json = jsonDecode(response.body);

    return json['message'] ?? 'Registro enviado correctamente';
  }

  Future<String> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/forgot-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'No se pudo generar el código de recuperación',
      );
    }

    final json = jsonDecode(response.body);

    /*
     * En producción NO se debe mostrar el código.
     * Ahorita lo devolvemos porque el backend está en modo desarrollo.
     */
    return json['code']?.toString() ?? '';
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/reset-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'code': code.trim(),
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'No se pudo actualizar la contraseña',
      );
    }

    final json = jsonDecode(response.body);

    return json['message'] ?? 'Contraseña actualizada correctamente';
  }

  Future<List<PendingUserModel>> getPendingUsers({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Admin/users/pending'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron obtener los usuarios pendientes',
      );
    }

    final List<dynamic> json = jsonDecode(response.body);

    return json
        .map(
          (item) => PendingUserModel.fromJson(item),
    )
        .toList();
  }

  Future<void> activateUser({
    required String token,
    required String userId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Admin/users/$userId/activate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo activar el usuario',
      );
    }
  }
}