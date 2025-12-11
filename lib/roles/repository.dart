import '../core/api_client.dart';
import 'model.dart';

class RolesRepository {
	RolesRepository(this.api);

	final ApiClient api;

	Future<Role> create(RoleCreate payload) async {
		final data = await api.post('/roles/', body: payload.toJson()) as Map<String, dynamic>;
		return Role.fromJson(data);
	}

	Future<List<Role>> listAll() async {
		final data = await api.get('/roles/') as List<dynamic>;
		return data.map((e) => Role.fromJson(e as Map<String, dynamic>)).toList();
	}
}