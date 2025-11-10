import 'package:afghan_bazar/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl =
      "https://sawdagar-api-serverv01-main-uyjtdt.laravel.cloud/api";
  static const String baseHost =
      "https://sawdagar-api-serverv01-main-uyjtdt.laravel.cloud";

  static UserModel? _currentUser;

  /// Load user once (call this during app startup)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("user_info");

    if (jsonString != null && jsonString.isNotEmpty) {
      final data = jsonDecode(jsonString);
      _currentUser = UserModel.fromJson(data);
    }
  }

  /// Sync getter – PURE UserModel (no Future)
  static UserModel? get getCurrentUser => _currentUser;

  /// Save tokens
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", accessToken);
    await prefs.setString("refresh_token", refreshToken);
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh_token");
  }

  /// Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Refresh token if expired
  static Future<bool> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/refresh"),
        headers: {"Accept": "application/json"},
        body: {"refresh_token": refreshToken},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data["access_token"] != null) {
          await saveTokens(data["access_token"], data["refresh_token"]);
          return true;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  /// Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
    await prefs.remove("refresh_token");
  }

  Future<http.Response> authGet(String endpoint) async {
    String? token = await AuthService.getAccessToken();

    var response = await http.get(
      Uri.parse("${AuthService.baseUrl}/$endpoint"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    // If unauthorized → try refresh
    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshToken();
      if (refreshed) {
        token = await AuthService.getAccessToken();
        response = await http.get(
          Uri.parse("${AuthService.baseUrl}/$endpoint"),
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        );
      }
    }

    return response;
  }

  Future<http.Response> authPost(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool isMultipart = false,
  }) async {
    String? token = await AuthService.getAccessToken();

    final requestHeaders = {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      if (!isMultipart) "Content-Type": "application/json",
      ...?headers,
    };

    var uri = Uri.parse("${AuthService.baseUrl}/$endpoint");

    http.Response response;

    if (isMultipart && body is http.MultipartRequest) {
      body.headers.addAll(requestHeaders);
      final streamed = await body.send();
      response = await http.Response.fromStream(streamed);
    } else {
      response = await http.post(uri, headers: requestHeaders, body: body);
    }

    // retry if unauthorized
    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshToken();
      if (refreshed) {
        token = await AuthService.getAccessToken();
        final retryHeaders = {
          "Authorization": "Bearer $token",
          if (!isMultipart) "Content-Type": "application/json",
          ...?headers,
        };

        if (isMultipart && body is http.MultipartRequest) {
          body.headers.remove("Authorization");
          body.headers.addAll(retryHeaders);
          final streamed = await body.send();
          response = await http.Response.fromStream(streamed);
        } else {
          response = await http.post(uri, headers: retryHeaders, body: body);
        }
      }
    }

    return response;
  }
}
