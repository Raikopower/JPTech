class MessageModel {
  final int id;
  final int solicitudId;
  final int emisorId;
  final int receptorId;
  final String? contenido;
  final String tipo;
  final String? imagenUrl;
  final double? latitud;
  final double? longitud;
  final bool leido;
  final String? emisorNombre;
  final String? emisorAvatar;
  final String? emisorRol;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.solicitudId,
    required this.emisorId,
    required this.receptorId,
    this.contenido,
    required this.tipo,
    this.imagenUrl,
    this.latitud,
    this.longitud,
    required this.leido,
    this.emisorNombre,
    this.emisorAvatar,
    this.emisorRol,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'],
    solicitudId: json['solicitud_id'],
    emisorId: json['emisor_id'],
    receptorId: json['receptor_id'],
    contenido: json['contenido'],
    tipo: json['tipo'] ?? 'texto',
    imagenUrl: json['imagen_url'],
    latitud: json['latitud'] != null ? double.tryParse(json['latitud'].toString()) : null,
    longitud: json['longitud'] != null ? double.tryParse(json['longitud'].toString()) : null,
    leido: json['leido'] == 1 || json['leido'] == true,
    emisorNombre: json['emisor_nombre'],
    emisorAvatar: json['emisor_avatar'],
    emisorRol: json['emisor_rol'],
    createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
  );
}
