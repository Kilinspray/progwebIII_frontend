import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiException extends HttpException {
  ApiException(this.statusCode, this.body, String message)
      : super(message);

  final int statusCode;
  final String body;
}

class ApiClient {
  // Singleton pattern - uma única instância compartilhada
  static final ApiClient _instance = ApiClient._internal();
  
  factory ApiClient() => _instance;
  
  ApiClient._internal() : _http = http.Client();

  static const String baseUrl = 'https://we3-backend.onrender.com';
  final http.Client _http;
  String? accessToken;

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => accessToken != null;

  /// Limpa o token (logout)
  void clearToken() {
    accessToken = null;
  }

  Uri _uri(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    return Uri.parse('$baseUrl$path');
  }

  Map<String, String> _headers({bool includeContentType = true}) {
    return {
      if (includeContentType) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  Future<dynamic> get(String path) async {
    final response = await _http.get(_uri(path), headers: _headers(includeContentType: false));
    return _handle(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _http.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? {}),
    );
    return _handle(response);
  }

  Future<dynamic> postForm(String path, Map<String, String> fields) async {
    final response = await _http.post(
      _uri(path),
      headers: {
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: fields,
    );
    return _handle(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await _http.put(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? {}),
    );
    return _handle(response);
  }

  Future<void> delete(String path) async {
    final response = await _http.delete(_uri(path), headers: _headers(includeContentType: false));
    _handle(response, expectBody: false);
  }

  dynamic _handle(http.Response response, {bool expectBody = true}) {
    final status = response.statusCode;
    final body = response.body;

    if (status >= 200 && status < 300) {
      if (!expectBody || body.isEmpty) return null;
      return jsonDecode(body);
    }

    throw ApiException(status, body, 'Request failed with status $status');
  }
}
