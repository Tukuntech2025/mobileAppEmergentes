import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tukuntech/core/auth_store.dart';
import 'package:tukuntech/core/environment_config.dart';

class ApiClient {
  static final http.Client _client = http.Client();
  static bool _isRefreshing = false;

  // Helper method to add default headers
  static Map<String, String> _getHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (AuthStore.token != null) {
      headers['Authorization'] = 'Bearer ${AuthStore.token}';
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  static Future<http.Response> _retryRequest(
    Future<http.Response> Function() requestFunc,
  ) async {
    final response = await requestFunc();
    
    // If the request fails with 401 or 403, and we have a refresh token
    if ((response.statusCode == 401 || response.statusCode == 403) && AuthStore.refreshToken != null) {
      return await _handleTokenRefresh(requestFunc);
    }
    
    return response;
  }

  static Future<http.Response> _handleTokenRefresh(Future<http.Response> Function() requestFunc) async {
    if (_isRefreshing) {
      // If a refresh is already in progress, wait for it to complete
      await Future.delayed(const Duration(seconds: 2));
      return await requestFunc();
    }

    _isRefreshing = true;
    try {
      final refreshUrl = '${EnvironmentConfig.baseUrl}/auth/refresh-token';
      final res = await _client.post(
        Uri.parse(refreshUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': AuthStore.refreshToken}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final newToken = data['accessToken'] ?? data['token'];
        final newRefreshToken = data['refreshToken'];

        if (newToken != null) {
          AuthStore.token = newToken;
          if (newRefreshToken != null) {
            AuthStore.refreshToken = newRefreshToken;
          }
          // Retry original request
          return await requestFunc();
        }
      }
      
      // If refresh failed, clear tokens
      AuthStore.clear();
      throw Exception('Session expired. Please log in again.');
      
    } catch (e) {
      AuthStore.clear();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return _retryRequest(() => _client.get(url, headers: _getHeaders(headers)));
  }

  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return _retryRequest(() => _client.post(url, headers: _getHeaders(headers), body: body, encoding: encoding));
  }

  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return _retryRequest(() => _client.put(url, headers: _getHeaders(headers), body: body, encoding: encoding));
  }

  static Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return _retryRequest(() => _client.delete(url, headers: _getHeaders(headers), body: body, encoding: encoding));
  }
}
