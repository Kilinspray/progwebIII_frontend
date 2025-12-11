class Transfer {
	const Transfer({
		required this.id,
		required this.valor,
		required this.data,
		required this.contaOrigemId,
		required this.contaDestinoId,
		required this.usuarioId,
	});

	final int id;
	final double valor;
	final DateTime data;
	final int contaOrigemId;
	final int contaDestinoId;
	final int usuarioId;

	factory Transfer.fromJson(Map<String, dynamic> json) {
		return Transfer(
			id: json['id'] as int,
			valor: (json['valor'] as num).toDouble(),
			data: DateTime.parse(json['data'] as String),
			contaOrigemId: json['conta_origem_id'] as int,
			contaDestinoId: json['conta_destino_id'] as int,
			usuarioId: json['usuario_id'] as int,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'valor': valor,
			'data': data.toIso8601String(),
			'conta_origem_id': contaOrigemId,
			'conta_destino_id': contaDestinoId,
			'usuario_id': usuarioId,
		};
	}
}

class TransferCreate {
	const TransferCreate({
		required this.valor,
		required this.data,
		this.contaOrigemId,
		required this.contaDestinoId,
	});

	final double valor;
	final DateTime data;
	final int? contaOrigemId;
	final int contaDestinoId;

	Map<String, dynamic> toJson() {
		return {
			'valor': valor,
			'data': data.toIso8601String().split('T').first,
			'conta_origem_id': contaOrigemId,
			'conta_destino_id': contaDestinoId,
		};
	}
}