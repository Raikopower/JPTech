class SolicitudModel {
  final int id;
  final String folio;
  final int clienteId;
  final int? tecnicoId;
  final int categoriaId;
  final String descripcion;
  final String urgencia;
  final String estado;
  final DateTime? fechaServicio;
  final String? horarioInicio;
  final String? horarioFin;
  final String direccion;
  final double? latitudCliente;
  final double? longitudCliente;
  final double? precioOferta;
  final double? precioFinal;
  final String? imagenProblemaUrl;
  final String? categoriaNombre;
  final String? tecnicoNombre;
  final String? tecnicoAvatar;
  final double? tecnicoCalificacion;
  final double? tecnicoLat;
  final double? tecnicoLng;
  final DateTime createdAt;

  SolicitudModel({
    required this.id,
    required this.folio,
    required this.clienteId,
    this.tecnicoId,
    required this.categoriaId,
    required this.descripcion,
    required this.urgencia,
    required this.estado,
    this.fechaServicio,
    this.horarioInicio,
    this.horarioFin,
    required this.direccion,
    this.latitudCliente,
    this.longitudCliente,
    this.precioOferta,
    this.precioFinal,
    this.imagenProblemaUrl,
    this.categoriaNombre,
    this.tecnicoNombre,
    this.tecnicoAvatar,
    this.tecnicoCalificacion,
    this.tecnicoLat,
    this.tecnicoLng,
    required this.createdAt,
  });

  factory SolicitudModel.fromJson(Map<String, dynamic> json) => SolicitudModel(
    id: json['id'],
    folio: json['folio'],
    clienteId: json['cliente_id'],
    tecnicoId: json['tecnico_id'],
    categoriaId: json['categoria_id'],
    descripcion: json['descripcion'],
    urgencia: json['urgencia'] ?? 'media',
    estado: json['estado'] ?? 'pendiente',
    fechaServicio: json['fecha_servicio'] != null ? DateTime.tryParse(json['fecha_servicio']) : null,
    horarioInicio: json['horario_inicio'],
    horarioFin: json['horario_fin'],
    direccion: json['direccion'],
    latitudCliente: json['latitud_cliente'] != null ? double.tryParse(json['latitud_cliente'].toString()) : null,
    longitudCliente: json['longitud_cliente'] != null ? double.tryParse(json['longitud_cliente'].toString()) : null,
    precioOferta: json['precio_oferta'] != null ? double.tryParse(json['precio_oferta'].toString()) : null,
    precioFinal: json['precio_final'] != null ? double.tryParse(json['precio_final'].toString()) : null,
    imagenProblemaUrl: json['imagen_problema_url'],
    categoriaNombre: json['categoria_nombre'],
    tecnicoNombre: json['tecnico_nombre'],
    tecnicoAvatar: json['tecnico_avatar'],
    tecnicoCalificacion: json['calificacion_promedio'] != null ? double.tryParse(json['calificacion_promedio'].toString()) : null,
    tecnicoLat: json['tecnico_lat'] != null ? double.tryParse(json['tecnico_lat'].toString()) : null,
    tecnicoLng: json['tecnico_lng'] != null ? double.tryParse(json['tecnico_lng'].toString()) : null,
    createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
  );
}

class CategoriaModel {
  final int id;
  final String nombre;
  final String? icono;
  final String? descripcion;

  CategoriaModel({required this.id, required this.nombre, this.icono, this.descripcion});

  factory CategoriaModel.fromJson(Map<String, dynamic> json) => CategoriaModel(
    id: json['id'],
    nombre: json['nombre'],
    icono: json['icono'],
    descripcion: json['descripcion'],
  );
}

class OfertaModel {
  final int id;
  final int solicitudId;
  final int tecnicoId;
  final double precio;
  final String? mensaje;
  final String estado;
  final String? nombre;
  final String? avatarUrl;
  final String? especialidad;
  final double calificacionPromedio;
  final int totalResenas;

  OfertaModel({
    required this.id,
    required this.solicitudId,
    required this.tecnicoId,
    required this.precio,
    this.mensaje,
    required this.estado,
    this.nombre,
    this.avatarUrl,
    this.especialidad,
    required this.calificacionPromedio,
    required this.totalResenas,
  });

  factory OfertaModel.fromJson(Map<String, dynamic> json) => OfertaModel(
    id: json['id'],
    solicitudId: json['solicitud_id'],
    tecnicoId: json['tecnico_id'],
    precio: double.tryParse(json['precio'].toString()) ?? 0,
    mensaje: json['mensaje'],
    estado: json['estado'] ?? 'pendiente',
    nombre: json['nombre'],
    avatarUrl: json['avatar_url'],
    especialidad: json['especialidad'],
    calificacionPromedio: double.tryParse(json['calificacion_promedio'].toString()) ?? 0,
    totalResenas: json['total_resenas'] ?? 0,
  );
}
