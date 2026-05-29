// ══════════════════════════════════════════════════════
//  MODELS  –  J&P Tech Support
// ══════════════════════════════════════════════════════

class UserModel {
  final int     id;
  final String  nombre;
  final String  correo;
  final String? telefono;
  final String  rol;
  final String? avatarUrl;
  final bool    verificado;
  final TechnicianProfile? profile;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    this.telefono,
    required this.rol,
    this.avatarUrl,
    this.verificado = false,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id:         j['id'] ?? 0,
    nombre:     j['nombre'] ?? j['name'] ?? '',
    correo:     j['correo'] ?? j['email'] ?? '',
    telefono:   j['telefono'] ?? j['phone'],
    rol:        j['rol'] ?? j['role'] ?? 'cliente',
    avatarUrl:  j['avatar_url'] ?? j['profile_image'],
    // FIX: MySQL devuelve 1/0 (int), no true/false (bool)
    verificado: j['verificado'] == 1 ||
                j['verificado'] == true ||
                j['verificado'] == '1',
    profile:    j['profile'] != null
                ? TechnicianProfile.fromJson(j['profile'])
                : (j['perfil_tecnico'] != null
                   ? TechnicianProfile.fromJson(j['perfil_tecnico'])
                   : null),
  );

  Map<String, dynamic> toJson() => {
    'id':         id,
    'nombre':     nombre,
    'correo':     correo,
    'telefono':   telefono,
    'rol':        rol,
    'avatar_url': avatarUrl,
    'verificado': verificado ? 1 : 0,
  };

  bool get isTechnician => rol == 'tecnico';
  bool get isCliente    => rol == 'cliente';
}

class TechnicianProfile {
  final int     id;
  final int     userId;
  final String  specialty;
  final int     yearsExperience;
  final double  rating;
  final int     totalReviews;
  final bool    isAvailable;
  final double? latitude;
  final double? longitude;

  TechnicianProfile({
    required this.id,
    required this.userId,
    required this.specialty,
    required this.yearsExperience,
    required this.rating,
    required this.totalReviews,
    required this.isAvailable,
    this.latitude,
    this.longitude,
  });

  factory TechnicianProfile.fromJson(Map<String, dynamic> j) => TechnicianProfile(
    id:              j['id'] ?? 0,
    userId:          j['user_id'] ?? 0,
    // FIX: backend usa 'especialidad', no 'specialty'
    specialty:       j['especialidad'] ?? j['specialty'] ?? '',
    // FIX: backend usa 'anios_experiencia', no 'years_experience'
    yearsExperience: j['anios_experiencia'] ?? j['years_experience'] ?? 0,
    // FIX: backend usa 'calificacion_promedio', no 'rating'
    rating:          double.tryParse(
                       (j['calificacion_promedio'] ?? j['rating'] ?? 0).toString()
                     ) ?? 0.0,
    // FIX: backend usa 'total_resenas', no 'total_reviews'
    totalReviews:    j['total_resenas'] ?? j['total_reviews'] ?? 0,
    // FIX: backend usa 'disponible', no 'is_available'
    isAvailable:     j['disponible'] == 1 ||
                     j['disponible'] == true ||
                     j['is_available'] == 1 ||
                     j['is_available'] == true,
    // FIX: backend usa 'latitud'/'longitud', no 'latitude'/'longitude'
    latitude:        j['latitud'] != null
                     ? double.tryParse(j['latitud'].toString())
                     : (j['latitude'] != null
                        ? double.tryParse(j['latitude'].toString())
                        : null),
    longitude:       j['longitud'] != null
                     ? double.tryParse(j['longitud'].toString())
                     : (j['longitude'] != null
                        ? double.tryParse(j['longitude'].toString())
                        : null),
  );
}

class ServiceCategory {
  final int    id;
  final String name;
  final String icon;

  ServiceCategory({required this.id, required this.name, required this.icon});

  factory ServiceCategory.fromJson(Map<String, dynamic> j) => ServiceCategory(
    id:   j['id'],
    // FIX: backend usa 'nombre', no 'name'
    name: j['nombre'] ?? j['name'] ?? '',
    icon: j['icono'] ?? j['icon'] ?? 'computer',
  );
}

class ServiceRequest {
  final int     id;
  final int     clientId;
  final int     categoryId;
  final String  categoryName;
  final String  description;
  final String  urgency;
  final String? scheduledDate;
  final String? scheduledTime;
  final String  address;
  final double  latitude;
  final double  longitude;
  final String  status;
  final String? folio;
  final String? technicianName;
  final String? technicianImage;
  final double? technicianRating;
  final double? finalPrice;
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.clientId,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.urgency,
    this.scheduledDate,
    this.scheduledTime,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.folio,
    this.technicianName,
    this.technicianImage,
    this.technicianRating,
    this.finalPrice,
    required this.createdAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> j) => ServiceRequest(
    id:               j['id'],
    // FIX: backend usa 'cliente_id', no 'client_id'
    clientId:         j['cliente_id']    ?? j['client_id']    ?? 0,
    // FIX: backend usa 'categoria_id', no 'category_id'
    categoryId:       j['categoria_id']  ?? j['category_id']  ?? 0,
    // FIX: backend usa 'categoria_nombre', no 'category_name'
    categoryName:     j['categoria_nombre'] ?? j['category_name'] ?? '',
    // FIX: backend usa 'descripcion', no 'description'
    description:      j['descripcion']   ?? j['description']  ?? '',
    // FIX: backend usa 'urgencia', no 'urgency'
    urgency:          j['urgencia']      ?? j['urgency']      ?? 'media',
    // FIX: backend usa 'fecha_servicio', no 'scheduled_date'
    scheduledDate:    j['fecha_servicio']  ?? j['scheduled_date'],
    // FIX: backend usa 'horario_inicio', no 'scheduled_time'
    scheduledTime:    j['horario_inicio']  ?? j['scheduled_time'],
    // FIX: backend usa 'direccion', no 'address'
    address:          j['direccion']     ?? j['address']      ?? '',
    // FIX: backend usa 'latitud_cliente', no 'latitude'
    latitude:         double.tryParse(
                        (j['latitud_cliente'] ?? j['latitude'] ?? 0).toString()
                      ) ?? 0,
    // FIX: backend usa 'longitud_cliente', no 'longitude'
    longitude:        double.tryParse(
                        (j['longitud_cliente'] ?? j['longitude'] ?? 0).toString()
                      ) ?? 0,
    // FIX: backend usa 'estado', no 'status'
    status:           j['estado']        ?? j['status']       ?? 'pendiente',
    folio:            j['folio'],
    // FIX: backend usa 'tecnico_nombre', no 'technician_name'
    technicianName:   j['tecnico_nombre']  ?? j['technician_name'],
    // FIX: backend usa 'tecnico_avatar', no 'technician_image'
    technicianImage:  j['tecnico_avatar']  ?? j['technician_image'],
    // FIX: backend usa 'calificacion_promedio', no 'technician_rating'
    technicianRating: j['calificacion_promedio'] != null
                      ? double.tryParse(j['calificacion_promedio'].toString())
                      : (j['technician_rating'] != null
                         ? double.tryParse(j['technician_rating'].toString())
                         : null),
    // FIX: backend usa 'precio_final', no 'final_price'
    finalPrice:       j['precio_final'] != null
                      ? double.tryParse(j['precio_final'].toString())
                      : (j['final_price'] != null
                         ? double.tryParse(j['final_price'].toString())
                         : null),
    createdAt:        DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
  );

  String get urgencyLabel =>
      urgency == 'alta'  ? 'URGENCIA ALTA'  :
      urgency == 'media' ? 'URGENCIA MEDIA' : 'URGENCIA BAJA';
}

class ServiceOffer {
  final int     id;
  final int     requestId;
  final int     technicianId;
  final String  technicianName;
  final String? technicianImage;
  final String  specialty;
  final double  rating;
  final int     totalReviews;
  final double  price;
  final String  status;

  ServiceOffer({
    required this.id,
    required this.requestId,
    required this.technicianId,
    required this.technicianName,
    this.technicianImage,
    required this.specialty,
    required this.rating,
    required this.totalReviews,
    required this.price,
    required this.status,
  });

  factory ServiceOffer.fromJson(Map<String, dynamic> j) => ServiceOffer(
    id:              j['id'],
    // FIX: backend usa 'solicitud_id', no 'request_id'
    requestId:       j['solicitud_id']   ?? j['request_id']   ?? 0,
    // FIX: backend usa 'tecnico_id', no 'technician_id'
    technicianId:    j['tecnico_id']     ?? j['technician_id'] ?? 0,
    // FIX: backend usa 'nombre', no 'name'
    technicianName:  j['nombre']         ?? j['name']         ?? '',
    // FIX: backend usa 'avatar_url', no 'profile_image'
    technicianImage: j['avatar_url']     ?? j['profile_image'],
    // FIX: backend usa 'especialidad', no 'specialty'
    specialty:       j['especialidad']   ?? j['specialty']    ?? '',
    // FIX: backend usa 'calificacion_promedio', no 'rating'
    rating:          double.tryParse(
                       (j['calificacion_promedio'] ?? j['rating'] ?? 0).toString()
                     ) ?? 0.0,
    // FIX: backend usa 'total_resenas', no 'total_reviews'
    totalReviews:    j['total_resenas']  ?? j['total_reviews'] ?? 0,
    // FIX: backend usa 'precio', no 'price'
    price:           double.tryParse(
                       (j['precio'] ?? j['price'] ?? 0).toString()
                     ) ?? 0.0,
    // FIX: backend usa 'estado', no 'status'
    status:          j['estado']         ?? j['status']       ?? 'pendiente',
  );
}

class ChatMessage {
  final int     id;
  final int     requestId;
  final int     senderId;
  final String  senderName;
  final String  senderRole;
  final String? senderImage;
  final String? content;
  final String  messageType;
  final bool    isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.senderImage,
    this.content,
    required this.messageType,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id:          j['id'],
    // FIX: backend usa 'solicitud_id', no 'request_id'
    requestId:   j['solicitud_id']  ?? j['request_id']  ?? 0,
    // FIX: backend usa 'emisor_id', no 'sender_id'
    senderId:    j['emisor_id']     ?? j['sender_id']   ?? 0,
    // FIX: backend usa 'emisor_nombre', no 'sender_name'
    senderName:  j['emisor_nombre'] ?? j['sender_name'] ?? '',
    // FIX: backend usa 'emisor_rol', no 'sender_role'
    senderRole:  j['emisor_rol']    ?? j['sender_role'] ?? 'cliente',
    // FIX: backend usa 'emisor_avatar', no 'sender_image'
    senderImage: j['emisor_avatar'] ?? j['sender_image'],
    // FIX: backend usa 'contenido', no 'content'
    content:     j['contenido']     ?? j['content'],
    // FIX: backend usa 'tipo', no 'message_type'
    messageType: j['tipo']          ?? j['message_type'] ?? 'texto',
    // FIX: MySQL devuelve 1/0 (int), no true/false (bool)
    isRead:      j['leido'] == 1    ||
                 j['leido'] == true ||
                 j['is_read'] == 1  ||
                 j['is_read'] == true,
    createdAt:   DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
  );
}

class MarketplaceLead {
  final int     leadId;
  final int     requestId;
  final String  description;
  final String  urgency;
  final String  address;
  final double  latitude;
  final double  longitude;
  final String  categoryName;
  final double  cost;
  final double? distanceKm;
  final DateTime publishedAt;

  MarketplaceLead({
    required this.leadId,
    required this.requestId,
    required this.description,
    required this.urgency,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.cost,
    this.distanceKm,
    required this.publishedAt,
  });

  factory MarketplaceLead.fromJson(Map<String, dynamic> j) => MarketplaceLead(
    // FIX: backend usa 'id', no 'lead_id'
    leadId:       j['id']          ?? j['lead_id']      ?? 0,
    // FIX: backend usa 'solicitud_id', no 'request_id'
    requestId:    j['solicitud_id'] ?? j['request_id']  ?? 0,
    // FIX: backend usa 'descripcion', no 'description'
    description:  j['descripcion'] ?? j['description']  ?? '',
    // FIX: backend usa 'urgencia', no 'urgency'
    urgency:      j['urgencia']    ?? j['urgency']      ?? 'media',
    // FIX: backend usa 'direccion', no 'address'
    address:      j['direccion']   ?? j['address']      ?? '',
    // FIX: backend usa 'latitud_cliente', no 'latitude'
    latitude:     double.tryParse(
                    (j['latitud_cliente'] ?? j['latitude'] ?? 0).toString()
                  ) ?? 0,
    // FIX: backend usa 'longitud_cliente', no 'longitude'
    longitude:    double.tryParse(
                    (j['longitud_cliente'] ?? j['longitude'] ?? 0).toString()
                  ) ?? 0,
    // FIX: backend usa 'categoria_nombre', no 'category_name'
    categoryName: j['categoria_nombre'] ?? j['category_name'] ?? '',
    // FIX: backend usa 'precio_lead', no 'cost'
    cost:         double.tryParse(
                    (j['precio_lead'] ?? j['cost'] ?? 0).toString()
                  ) ?? 0.0,
    // FIX: backend usa 'distancia_km', no 'distance_km'
    distanceKm:   j['distancia_km'] != null
                  ? double.tryParse(j['distancia_km'].toString())
                  : (j['distance_km'] != null
                     ? double.tryParse(j['distance_km'].toString())
                     : null),
    // FIX: backend usa 'created_at', no 'published_at'
    publishedAt:  DateTime.tryParse(
                    j['solicitud_fecha'] ?? j['created_at'] ?? j['published_at'] ?? ''
                  ) ?? DateTime.now(),
  );

  String get urgencyLabel =>
      urgency == 'alta'  ? 'URGENCIA ALTA'  :
      urgency == 'media' ? 'URGENCIA MEDIA' : 'URGENCIA BAJA';
}