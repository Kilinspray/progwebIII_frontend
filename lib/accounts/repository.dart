import '../core/api_client.dart';
import 'model.dart';

class AccountsRepository {
	AccountsRepository(this.api);

	final ApiClient api;

	Future<Account> create(AccountCreate payload) async {
		final data = await api.post('/accounts/', body: payload.toJson()) as Map<String, dynamic>;
		return Account.fromJson(data);
	}

	Future<List<Account>> listAll() async {
		final data = await api.get('/accounts/') as List<dynamic>;
		return data.map((e) => Account.fromJson(e as Map<String, dynamic>)).toList();
	}

	Future<Account> getById(int id) async {
		final data = await api.get('/accounts/$id') as Map<String, dynamic>;
		return Account.fromJson(data);
	}

	Future<Account> update(int id, AccountUpdate payload) async {
		final data = await api.put('/accounts/$id', body: payload.toJson()) as Map<String, dynamic>;
		return Account.fromJson(data);
	}

	Future<void> delete(int id) async {
		await api.delete('/accounts/$id');
	}

	// Método admin
	Future<List<Account>> listAllAdmin() async {
		final data = await api.get('/accounts/admin/all') as List<dynamic>;
		return data.map((e) => Account.fromJson(e as Map<String, dynamic>)).toList();
	}
}