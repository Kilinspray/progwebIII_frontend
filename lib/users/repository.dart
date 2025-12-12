import '../core/api_client.dart';
import 'model.dart';

class UsersRepository {
	UsersRepository(this.api);

	final ApiClient api;

	Future<User> create(UserCreate payload) async {
		final data = await api.post('/users/', body: payload.toJson()) as Map<String, dynamic>;
		return User.fromJson(data);
	}

	Future<List<User>> listAll() async {
		final data = await api.get('/users/') as List<dynamic>;
		return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
	}

	Future<User> update(int id, UserUpdate payload) async {
		final data = await api.put('/users/$id', body: payload.toJson()) as Map<String, dynamic>;
		return User.fromJson(data);
	}

	Future<void> delete(int id) async {
		await api.delete('/users/$id');
	}

	// Métodos para usuário logado
	Future<User> getCurrentUser() async {
		final data = await api.get('/users/me') as Map<String, dynamic>;
		return User.fromJson(data);
	}

	Future<User> updateMyAvatar(String profileImageBase64) async {
		final data = await api.put(
			'/users/me/avatar',
			body: {'profile_image_base64': profileImageBase64},
		) as Map<String, dynamic>;
		return User.fromJson(data);
	}

	Future<User> updateMyProfile(UserUpdate payload) async {
		final data = await api.put('/users/me', body: payload.toJson()) as Map<String, dynamic>;
		return User.fromJson(data);
	}
}