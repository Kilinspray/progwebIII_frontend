import '../core/api_client.dart';
import 'model.dart';

class CategoriesRepository {
	CategoriesRepository(this.api);

	final ApiClient api;

	Future<Category> create(CategoryCreate payload) async {
		final data = await api.post('/categories/', body: payload.toJson()) as Map<String, dynamic>;
		return Category.fromJson(data);
	}

	Future<List<Category>> listAll() async {
		final data = await api.get('/categories/') as List<dynamic>;
		return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
	}

	Future<Category> getById(int id) async {
		final data = await api.get('/categories/$id') as Map<String, dynamic>;
		return Category.fromJson(data);
	}

	Future<Category> update(int id, CategoryUpdate payload) async {
		final data = await api.put('/categories/$id', body: payload.toJson()) as Map<String, dynamic>;
		return Category.fromJson(data);
	}

	Future<void> delete(int id) async {
		await api.delete('/categories/$id');
	}
}