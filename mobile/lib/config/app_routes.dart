class AppRoutes {
  // Auth
  static const String login              = '/login';
  static const String registerClient     = '/register-client';
  static const String registerTechnician = '/register-technician';
  static const String verifyCode         = '/verify-code';
  static const String forgotPassword     = '/forgot-password';

  // Client
  static const String clientHome         = '/client/home';
  static const String serviceRequest     = '/client/service-request';
  static const String schedule           = '/client/schedule';
  static const String requestSummary     = '/client/request-summary';
  static const String searching          = '/client/searching';
  static const String offers             = '/client/offers';
  static const String bookingConfirmed   = '/client/booking-confirmed';
  static const String clientChat         = '/client/chat';
  static const String rateService        = '/client/rate-service';
  static const String clientProfile      = '/client/profile';

  // Technician
  static const String techDashboard      = '/tech/dashboard';
  static const String techMarketplace    = '/tech/marketplace';
  static const String techServiceDetail  = '/tech/service-detail';
  static const String techNavigation     = '/tech/navigation';
  static const String techChat           = '/tech/chat';
  static const String techServiceSummary = '/tech/service-summary';
  static const String techProfile        = '/tech/profile';
}
