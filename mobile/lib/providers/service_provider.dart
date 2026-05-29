import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ServiceProvider extends ChangeNotifier {
  List<SolicitudModel> _solicitudes = [];
  List<CategoriaModel> _categorias = [];
  List<OfertaModel> _ofertas = [];
  List<MessageModel> _mensajes = [];
  bool _loading = false;

  List<SolicitudModel> get solicitudes => _solicitudes;
  List<CategoriaModel> get categorias => _categorias;
  List<OfertaModel> get ofertas => _ofertas;
  List<MessageModel> get mensajes => _mensajes;
  bool get loading => _loading;

  Future<void> loadCategorias() async {
    final result = await ApiService.get(ApiConfig.categorias);
    if (result['success']) {
      _categorias = (result['data'] as List).map((e) => CategoriaModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> loadMisSolicitudes() async {
    _loading = true;
    notifyListeners();
    try {
      final result = await ApiService.get('${ApiConfig.services}/mis-solicitudes');
      if (result['success']) {
        _solicitudes = (result['data'] as List).map((e) => SolicitudModel.fromJson(e)).toList();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> crearSolicitud(Map<String, dynamic> data) async {
    return await ApiService.post(ApiConfig.services, data);
  }

  Future<void> loadOfertas(int solicitudId) async {
    final result = await ApiService.get(ApiConfig.techOffers(solicitudId));
    if (result['success']) {
      _ofertas = (result['data'] as List).map((e) => OfertaModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> loadMensajes(int solicitudId) async {
    final result = await ApiService.get(ApiConfig.chat(solicitudId));
    if (result['success']) {
      _mensajes = (result['data'] as List).map((e) => MessageModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  void addMensaje(MessageModel msg) {
    _mensajes.add(msg);
    notifyListeners();
  }

  void addOferta(OfertaModel oferta) {
    _ofertas.add(oferta);
    notifyListeners();
  }

  void clearMensajes() {
    _mensajes = [];
    notifyListeners();
  }
}
