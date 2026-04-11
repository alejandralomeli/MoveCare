class Auditoria {
  final String idAuditoria;
  final String idAdmin;
  final String nombreAdmin; // <-- ¡Nuevo!
  final String accion;
  final String tablaAfectada;
  final String? idObjetivo;
  final String? detalle;
  final DateTime fecha;
  final String? ipOrigen;
  final String? estadoValidacion; // <-- ¡Nuevo!
  final String? motivoRechazo;    // <-- ¡Nuevo!

  Auditoria({
    required this.idAuditoria,
    required this.idAdmin,
    required this.nombreAdmin,
    required this.accion,
    required this.tablaAfectada,
    this.idObjetivo,
    this.detalle,
    required this.fecha,
    this.ipOrigen,
    this.estadoValidacion,
    this.motivoRechazo,
  });

  factory Auditoria.fromJson(Map<String, dynamic> json) {
    return Auditoria(
      idAuditoria: json['id_auditoria'] ?? '',
      idAdmin: json['id_admin'] ?? '',
      nombreAdmin: json['nombre_admin'] ?? 'Admin Desconocido', // Valor por defecto por seguridad
      accion: json['accion'] ?? '',
      tablaAfectada: json['tabla_afectada'] ?? '',
      idObjetivo: json['id_objetivo'],
      detalle: json['detalle'],
      fecha: DateTime.parse(json['fecha']),
      ipOrigen: json['ip_origen'],
      estadoValidacion: json['estado_validacion'],
      motivoRechazo: json['motivo_rechazo'],
    );
  }
}