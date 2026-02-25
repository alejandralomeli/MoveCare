class UserModel {
  final String idUsuario;
  final String nombre;
  final String correo;
  final String rol;
  final bool activo;

  UserModel({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.activo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUsuario: json['id_usuario'] ?? '',
      nombre: json['nombre_completo'] ?? '',
      correo: json['correo'] ?? '',
      rol: json['rol'] ?? '',
      activo: json['activo'] ?? false, 
    );
  }
}
