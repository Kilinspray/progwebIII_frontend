import '../core/api_client.dart';
import 'model.dart';

class TransfersRepository {
	TransfersRepository(this.api);

	final ApiClient api;

	Future<Transfer> create(TransferCreate payload) async {
		final data = await api.post('/transfers/', body: payload.toJson()) as Map<String, dynamic>;
		return Transfer.fromJson(data);
	}

	Future<List<Transfer>> listAll() async {
		final data = await api.get('/transfers/') as List<dynamic>;
		return data.map((e) => Transfer.fromJson(e as Map<String, dynamic>)).toList();
	}

	Future<Transfer> getById(int id) async {
		final data = await api.get('/transfers/$id') as Map<String, dynamic>;
		return Transfer.fromJson(data);
	}

	Future<void> delete(int id) async {
		await api.delete('/transfers/$id');
	}

	// Método admin
	Future<List<Transfer>> listAllAdmin() async {
		final data = await api.get('/transfers/admin/all') as List<dynamic>;
		return data.map((e) => Transfer.fromJson(e as Map<String, dynamic>)).toList();
	}
}