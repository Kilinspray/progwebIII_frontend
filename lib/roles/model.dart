class Role {
	const Role({
		required this.id,
		required this.name,
	});

	final int id;
	final String name;

	factory Role.fromJson(Map<String, dynamic> json) {
		return Role(
			id: json['id'] as int,
			name: json['name'] as String,
		);
	}

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
			};
}

class RoleCreate {
	const RoleCreate({required this.name});
	final String name;

	Map<String, dynamic> toJson() => {'name': name};
}