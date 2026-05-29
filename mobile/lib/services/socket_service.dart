import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';

class SocketService {
  static IO.Socket? _socket;

  static void connect(String token) {
    _socket = IO.io(ApiConfig.socketUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .enableAutoConnect()
      .build());

    _socket!.connect();
    _socket!.onConnect((_) => print('🔌 Socket conectado'));
    _socket!.onDisconnect((_) => print('🔌 Socket desconectado'));
    _socket!.onError((err) => print('❌ Socket error: $err'));
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  static void joinSolicitud(int solicitudId) {
    _socket?.emit('join_solicitud', solicitudId);
  }

  static void leaveSolicitud(int solicitudId) {
    _socket?.emit('leave_solicitud', solicitudId);
  }

  static void updateLocation(int? solicitudId, double lat, double lng) {
    _socket?.emit('update_location', {'solicitud_id': solicitudId, 'latitud': lat, 'longitud': lng});
  }

  static void enCamino(int solicitudId) {
    _socket?.emit('en_camino', {'solicitud_id': solicitudId});
  }

  static void llegueDestino(int solicitudId) {
    _socket?.emit('llegue_destino', {'solicitud_id': solicitudId});
  }

  static void sendTyping(int solicitudId) {
    _socket?.emit('typing', {'solicitud_id': solicitudId});
  }

  static void stopTyping(int solicitudId) {
    _socket?.emit('stop_typing', {'solicitud_id': solicitudId});
  }

  static void onNuevaMensaje(Function(dynamic) callback) {
    _socket?.on('nuevo_mensaje', callback);
  }

  static void onEstadoActualizado(Function(dynamic) callback) {
    _socket?.on('estado_actualizado', callback);
  }

  static void onTecnicoUbicacion(Function(dynamic) callback) {
    _socket?.on('tecnico_ubicacion', callback);
  }

  static void onNuevaOferta(Function(dynamic) callback) {
    _socket?.on('nueva_oferta', callback);
  }

  static void onOfertaAceptada(Function(dynamic) callback) {
    _socket?.on('oferta_aceptada', callback);
  }

  static void onNuevaSolicitud(Function(dynamic) callback) {
    _socket?.on('nueva_solicitud', callback);
  }

  static void onTecnicoLlego(Function(dynamic) callback) {
    _socket?.on('tecnico_llego', callback);
  }

  static void offEvent(String event) {
    _socket?.off(event);
  }

  static bool get isConnected => _socket?.connected ?? false;
}
