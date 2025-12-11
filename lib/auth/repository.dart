import '../core/api_client.dart';

class AuthRepository {
  AuthRepository(this.api);

  final ApiClient api;

  Future<String> login({required String email, required String password}) async {
    final data = await api.postForm('/auth/login', {
      'username': email,
      'password': password,
    }) as Map<String, dynamic>;

    final token = data['access_token'] as String;
    api.accessToken = token;
    return token;
  }
}
