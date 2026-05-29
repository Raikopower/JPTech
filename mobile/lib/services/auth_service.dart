import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _loading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null && _token != null;
  bool get isCliente => _user?.rol == 'cliente';
  bool get isTecnico => _user?.rol == 'tecnico';

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');
    if (_token != null && userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
      SocketService.connect(_token!);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String correo, String password, String rol) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await ApiService.post(
        ApiConfig.login,
        {'correo': correo, 'password': password, 'rol': rol},
        withAuth: false,
      );
      if (result['success']) {
        _token = result['data']['token'];
        _user = UserModel.fromJson(result['data']['user']);
        await _saveToStorage();
        SocketService.connect(_token!);
      }
      return result;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> registerCliente(Map<String, dynamic> data) async {
    _loading = true;
    notifyListeners();
    try {
      return await ApiService.post(ApiConfig.registerCliente, data, withAuth: false);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    SocketService.disconnect();
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString('auth_token', _token!);
    if (_user != null) {
      await prefs.setString('user_data', jsonEncode({
        'id': _user!.id,
        'nombre': _user!.nombre,
        'correo': _user!.correo,
        'telefono': _user!.telefono,
        'rol': _user!.rol,
        'avatar_url': _user!.avatarUrl,
        'verificado': _user!.verificado,
      }));
    }
  }
}