class ApiConfig {
  // Cambiar por tu IP local cuando ejecutes en dispositivo físico
  // Para emulador Android: 10.0.2.2
  // Para dispositivo físico: 192.168.x.x (tu IP local)
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String socketUrl = 'http://10.0.2.2:3000';
  
  // Endpoints Auth
  static const String login = '$baseUrl/auth/login';
  static const String registerCliente = '$baseUrl/auth/register/cliente';
  static const String registerTecnico = '$baseUrl/auth/register/tecnico';
  static const String verify = '$baseUrl/auth/verify';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String profile = '$baseUrl/auth/profile';

  // Alias usados en auth_service
  static const String registerClient     = registerCliente;
  static const String registerTechnician = registerTecnico;
  static const String verifyOtp          = verify;
  static const String me                 = profile;
  static const String resendOtp          = '$baseUrl/auth/resend-otp';
  
  // Endpoints Services
  static const String services = '$baseUrl/services';
  static String serviceById(int id) => '$baseUrl/services/$id';
  static String serviceEstado(int id) => '$baseUrl/services/$id/estado';
  static String serviceFinalizar(int id) => '$baseUrl/services/$id/finalizar';
  static const String categorias = '$baseUrl/services/categorias';
  
  // Endpoints Technicians
  static const String nearbyTechs = '$baseUrl/technicians/nearby';
  static const String techOffer = '$baseUrl/technicians/offer';
  static String techOffers(int solicitudId) => '$baseUrl/technicians/offers/$solicitudId';
  static String acceptOffer(int ofertaId) => '$baseUrl/technicians/accept-offer/$ofertaId';
  static const String techLocation = '$baseUrl/technicians/location';
  static const String techAvailability = '$baseUrl/technicians/availability';
  static const String marketplace = '$baseUrl/technicians/marketplace';
  
  // Endpoints Chat
  static String chat(int solicitudId) => '$baseUrl/chat/$solicitudId';
  
  // Endpoints Ratings
  static const String ratings = '$baseUrl/ratings';
  static String ratingsByTech(int techId) => '$baseUrl/ratings/tecnico/$techId';
}