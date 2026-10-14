import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  final ApiClient api;
  final TokenStorage storage;
  Map<String, dynamic>? currentUser;

  AuthRepository(this.api, this.storage);

  /// Converts API and transport errors into messages suitable for the UI.
  String friendlyErrorMessage(Object error, {String? action}) {
    if (error is! DioException) {
      return 'Something went wrong. Please try again.';
    }

    final status = error.response?.statusCode;
    final path = error.requestOptions.path;
    final isLogin = path.endsWith('/auth/login');

    if (status != null && status >= 500) {
      return 'The server encountered a problem. Please try again later.';
    }

    switch (status) {
      case 400:
        final message = error.response?.data is Map
            ? error.response?.data['message']
            : null;
        if (message is List && message.isNotEmpty) {
          return message.join(' ');
        }
        return message is String
            ? message
            : 'Please check the information you entered.';
      case 401:
        return isLogin
            ? 'The email or password is incorrect.'
            : 'Your session has expired. Please log in again.';
      case 403:
        return 'You do not have permission to do that.';
      case 404:
        return action == 'profile'
            ? 'The profile endpoint was not found. Rebuild and restart the backend, then try again.'
            : 'The requested item could not be found.';
      case 409:
        return 'An account with this email already exists.';
      case 429:
        return 'Too many attempts. Please wait a moment and try again.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server. Check that it is running and your phone is on the same Wi-Fi network.';
    }

    return 'Could not complete the request. Please try again.';
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await api.dio.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data;

      if (data is! Map ||
          data['accessToken'] is! String ||
          data['refreshToken'] is! String) {
        throw const FormatException(
          'Invalid registration response from server.',
        );
      }

      await _save(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      debugPrint('REGISTER ERROR: ${e.type}');
      debugPrint('STATUS: ${e.response?.statusCode}');
      debugPrint('RESPONSE: ${e.response?.data}');

      rethrow;
    } catch (e) {
      debugPrint('UNEXPECTED REGISTER ERROR: $e');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    final r = await api.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    await _save(r.data);
  }

  Future<Map<String, dynamic>> me() async =>
      (await api.dio.get('/users/me')).data;


  Future<List<dynamic>> adminUsers() async =>
      (await api.dio.get('/users')).data;

  Future<Map<String, dynamic>> updateUserRole(int id, String role) async {
    final response = await api.dio.patch(
      '/users/$id/role',
      data: {'role': role},
    );
    if (response.data is! Map) {
      throw const FormatException('Invalid user response from server.');
    }
    return Map<String, dynamic>.from(response.data as Map);
  }

      
  Future<void> logout() async {
    final refresh = await storage.refreshToken;
    try {
      await api.dio.post('/auth/logout', data: {'refreshToken': refresh ?? ''});
    } finally {
      await storage.clear();
    }
  }

  Future<void> _save(dynamic data) async {
    if (data is! Map ||
        data['accessToken'] is! String ||
        data['refreshToken'] is! String) {
      throw const FormatException('Invalid authentication response from server.');
    }

    await storage.save(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );

    final user = data['user'];
    currentUser = user is Map ? Map<String, dynamic>.from(user) : null;
  }
}
