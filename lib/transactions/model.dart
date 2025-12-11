import '../categories/model.dart';

class Transaction {
	const Transaction({
		required this.id,
		this.descricao,
		required this.valor,
		required this.tipo,
		required this.data,
		required this.contaId,
		this.categoriaId,
		required this.usuarioId,
	});

	final int id;
	final String? descricao;
	final double valor;
	final CategoryType tipo;
	final DateTime data;
	final int contaId;
	final int? categoriaId;
	final int usuarioId;

	factory Transaction.fromJson(Map<String, dynamic> json) {
		return Transaction(
			id: json['id'] as int,
			descricao: json['descricao'] as String?,
			valor: (json['valor'] as num).toDouble(),
			tipo: CategoryType.fromApi(json['tipo'] as String),
			data: DateTime.parse(json['data'] as String),
			contaId: json['conta_id'] as int,
			categoriaId: json['categoria_id'] as int?,
			usuarioId: json['usuario_id'] as int,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'descricao': descricao,
			'valor': valor,
			'tipo': tipo.apiValue,
			'data': data.toIso8601String(),
			'conta_id': contaId,
			'categoria_id': categoriaId,
			'usuario_id': usuarioId,
		};
	}
}

class TransactionCreate {
	const TransactionCreate({
		this.descricao,
		required this.valor,
		required this.tipo,
		required this.data,
		required this.contaId,
		this.categoriaId,
	});

	final String? descricao;
	final double valor;
	final CategoryType tipo;
	final DateTime data;
	final int contaId;
	final int? categoriaId;

	Map<String, dynamic> toJson() {
		return {
			'descricao': descricao,
			'valor': valor,
			'tipo': tipo.apiValue,
			'data': data.toIso8601String().split('T').first,
			'conta_id': contaId,
			'categoria_id': categoriaId,
		};
	}
}

class TransactionUpdate {
	const TransactionUpdate({
		this.descricao,
		this.data,
		this.contaId,
		this.categoriaId,
	});

	final String? descricao;
	final DateTime? data;
	final int? contaId;
	final int? categoriaId;

	Map<String, dynamic> toJson() {
		return {
			if (descricao != null) 'descricao': descricao,
			if (data != null) 'data': data!.toIso8601String().split('T').first,
			if (contaId != null) 'conta_id': contaId,
			if (categoriaId != null) 'categoria_id': categoriaId,
		};
	}
}