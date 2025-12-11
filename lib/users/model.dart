import '../roles/model.dart';

enum CurrencyType {
	brl('BRL'),
	usd('USD'),
	eur('EUR'),
	gbp('GBP'),
	jpy('JPY'),
	cny('CNY'),
	cad('CAD'),
	aud('AUD'),
	chf('CHF'),
	inr('INR');

	const CurrencyType(this.apiValue);
	final String apiValue;

	static CurrencyType fromApi(String value) {
		return CurrencyType.values.firstWhere(
			(e) => e.apiValue.toLowerCase() == value.toLowerCase(),
			orElse: () => throw ArgumentError('Unknown currency: $value'),
		);
	}
}

class User {
	const User({
		required this.id,
		required this.email,
		required this.nome,
		required this.moeda,
		this.profileImageUrl,
		required this.role,
	});

	final int id;
	final String email;
	final String? nome;
	final CurrencyType moeda;
	final String? profileImageUrl;
	final Role role;

	factory User.fromJson(Map<String, dynamic> json) {
		return User(
			id: json['id'] as int,
			email: json['email'] as String,
			nome: json['nome'] as String?,
			moeda: CurrencyType.fromApi(json['moeda'] as String),
			profileImageUrl: json['profile_image_url'] as String?,
			role: Role.fromJson(json['role'] as Map<String, dynamic>),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'email': email,
			'nome': nome,
			'moeda': moeda.apiValue,
			'profile_image_url': profileImageUrl,
			'role': role.toJson(),
		};
	}
}

class UserCreate {
	const UserCreate({
		required this.email,
		required this.password,
		this.nome,
		this.moeda = CurrencyType.brl,
		this.profileImageUrl,
		required this.roleId,
	});

	final String email;
	final String password;
	final String? nome;
	final CurrencyType moeda;
	final String? profileImageUrl;
	final int roleId;

	Map<String, dynamic> toJson() {
		return {
			'email': email,
			'password': password,
			'nome': nome,
			'moeda': moeda.apiValue,
			'profile_image_url': profileImageUrl,
			'role_id': roleId,
		};
	}
}

class UserUpdate {
	const UserUpdate({
		this.nome,
		this.moeda,
		this.profileImageUrl,
	});

	final String? nome;
	final CurrencyType? moeda;
	final String? profileImageUrl;

	Map<String, dynamic> toJson() {
		return {
			if (nome != null) 'nome': nome,
			if (moeda != null) 'moeda': moeda!.apiValue,
			if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
		};
	}
}