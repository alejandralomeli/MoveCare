class UserModel {
  final String idUsuario;
  final String nombre;
  final String correo;
  final String telefono;
  final String direccion;
  final String fechaNacimiento;
  final String fotoPerfil;
  final String discapacidad;
  final String rol;
  final bool activo;

  UserModel({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.direccion,
    required this.fechaNacimiento,
    required this.fotoPerfil,
    required this.discapacidad,
    required this.rol,
    required this.activo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUsuario: json['id_usuario'] ?? '',
      nombre: json['nombre_completo'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] ?? '',
      fotoPerfil: json['foto_perfil'] ?? '',
      discapacidad: json['discapacidad'] ?? '',
      rol: json['rol'] ?? '',
      activo: json['activo'] ?? false,
    );
  }
}
