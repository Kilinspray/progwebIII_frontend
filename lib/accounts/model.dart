enum AccountType {
	carteira('Carteira'),
	banco('Banco'),
	cofre('Cofre'),
	investimento('Investimento'),
	outros('Outros');

	const AccountType(this.apiValue);
	final String apiValue;

	static AccountType fromApi(String value) {
		return AccountType.values.firstWhere(
			(e) => e.apiValue.toLowerCase() == value.toLowerCase(),
			orElse: () => throw ArgumentError('Unknown account type: $value'),
		);
	}
}

class Account {
	const Account({
		required this.id,
		required this.nome,
		required this.tipo,
		required this.saldoInicial,
		required this.saldoAtual,
		this.limiteCredito,
		required this.usuarioId,
	});

	final int id;
	final String nome;
	final AccountType tipo;
	final double saldoInicial;
	final double saldoAtual;
	final double? limiteCredito;
	final int usuarioId;

	factory Account.fromJson(Map<String, dynamic> json) {
		return Account(
			id: json['id'] as int,
			nome: json['nome'] as String,
			tipo: AccountType.fromApi(json['tipo'] as String),
			saldoInicial: (json['saldo_inicial'] as num).toDouble(),
			saldoAtual: (json['saldo_atual'] as num).toDouble(),
			limiteCredito: (json['limite_credito'] as num?)?.toDouble(),
			usuarioId: json['usuario_id'] as int,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'nome': nome,
			'tipo': tipo.apiValue,
			'saldo_inicial': saldoInicial,
			'saldo_atual': saldoAtual,
			'limite_credito': limiteCredito,
			'usuario_id': usuarioId,
		};
	}
}

class AccountCreate {
	const AccountCreate({
		required this.nome,
		required this.tipo,
		this.saldoInicial = 0,
		this.limiteCredito,
	});

	final String nome;
	final AccountType tipo;
	final double saldoInicial;
	final double? limiteCredito;

	Map<String, dynamic> toJson() {
		return {
			'nome': nome,
			'tipo': tipo.apiValue,
			'saldo_inicial': saldoInicial,
			'limite_credito': limiteCredito,
		};
	}
}

class AccountUpdate {
	const AccountUpdate({
		this.nome,
		this.tipo,
		this.limiteCredito,
	});

	final String? nome;
	final AccountType? tipo;
	final double? limiteCredito;

	Map<String, dynamic> toJson() {
		return {
			if (nome != null) 'nome': nome,
			if (tipo != null) 'tipo': tipo!.apiValue,
			if (limiteCredito != null) 'limite_credito': limiteCredito,
		};
	}
}