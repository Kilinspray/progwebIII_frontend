import '../core/api_client.dart';
import 'model.dart';

class TransactionsRepository {
	TransactionsRepository(this.api);

	final ApiClient api;

	Future<Transaction> create(TransactionCreate payload) async {
		final data = await api.post('/transactions/', body: payload.toJson()) as Map<String, dynamic>;
		return Transaction.fromJson(data);
	}

	Future<List<Transaction>> listAll() async {
		final data = await api.get('/transactions/') as List<dynamic>;
		return data.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
	}

	Future<Transaction> getById(int id) async {
		final data = await api.get('/transactions/$id') as Map<String, dynamic>;
		return Transaction.fromJson(data);
	}

	Future<Transaction> update(int id, TransactionUpdate payload) async {
		final data = await api.put('/transactions/$id', body: payload.toJson()) as Map<String, dynamic>;
		return Transaction.fromJson(data);
	}

	Future<void> delete(int id) async {
		await api.delete('/transactions/$id');
	}
}