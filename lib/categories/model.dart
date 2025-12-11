enum CategoryType {
	despesa('Despesa'),
	receita('Receita');

	const CategoryType(this.apiValue);
	final String apiValue;

	static CategoryType fromApi(String value) {
		return CategoryType.values.firstWhere(
			(e) => e.apiValue.toLowerCase() == value.toLowerCase(),
			orElse: () => throw ArgumentError('Unknown category type: $value'),
		);
	}
}

class Category {
	const Category({
		required this.id,
		required this.nome,
		required this.tipo,
		required this.usuarioId,
	});

	final int id;
	final String nome;
	final CategoryType tipo;
	final int usuarioId;

	factory Category.fromJson(Map<String, dynamic> json) {
		return Category(
			id: json['id'] as int,
			nome: json['nome'] as String,
			tipo: CategoryType.fromApi(json['tipo'] as String),
			usuarioId: json['usuario_id'] as int,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'nome': nome,
			'tipo': tipo.apiValue,
			'usuario_id': usuarioId,
		};
	}
}

class CategoryCreate {
	const CategoryCreate({
		required this.nome,
		required this.tipo,
	});

	final String nome;
	final CategoryType tipo;

	Map<String, dynamic> toJson() => {
				'nome': nome,
				'tipo': tipo.apiValue,
			};
}

class CategoryUpdate {
	const CategoryUpdate({
		this.nome,
		this.tipo,
	});

	final String? nome;
	final CategoryType? tipo;

	Map<String, dynamic> toJson() {
		return {
			if (nome != null) 'nome': nome,
			if (tipo != null) 'tipo': tipo!.apiValue,
		};
	}
}