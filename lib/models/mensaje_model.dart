class MensajeModel {
  final int idMensaje;
  final String idViaje;
  final String idEmisor;
  final String contenido;
  final DateTime fechaEnvio;

  MensajeModel({
    required this.idMensaje,
    required this.idViaje,
    required this.idEmisor,
    required this.contenido,
    required this.fechaEnvio,
  });

  factory MensajeModel.fromJson(Map<String, dynamic> json) {
    return MensajeModel(
      idMensaje: json['id_mensaje'],
      idViaje: json['id_viaje'],
      idEmisor: json['id_emisor'],
      contenido: json['contenido'],
      // Parseamos la fecha y la convertimos a la zona horaria local del dispositivo
      fechaEnvio: DateTime.parse(json['fecha_envio']).toLocal(),
    );
  }
}