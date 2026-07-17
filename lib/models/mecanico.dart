class Mecanico {
  const Mecanico({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
  });

  final int id;
  final String nome;
  final String email;
  final String role;

  bool get isAdmin => role == 'admin';

  factory Mecanico.fromJson(Map<String, dynamic> json) {
    return Mecanico(
      id: json['id'] as int,
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'mecanico',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'role': role,
      };
}
