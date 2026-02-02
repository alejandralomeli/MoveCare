class UserModel {
  final String idUsuario;
  final String nombre;
  final String correo;
  final String rol;

  UserModel({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUsuario: json['id_usuario'],
      nombre: json['nombre_completo'] ?? '',
      correo: json['correo'],
      rol: json['rol'],
    );
  }
}
