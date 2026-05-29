import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../config/app_colors.dart';
import '../../services/location_service.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../client/chat_screen.dart';
import 'service_summary_screen.dart';

class NavigationScreen extends StatefulWidget {
  final int solicitudId;
  final String folio;
  final String clienteNombre;
  final String descripcion;
  final double latCliente;
  final double lngCliente;

  const NavigationScreen({
    super.key,
    required this.solicitudId,
    required this.folio,
    required this.clienteNombre,
    required this.descripcion,
    required this.latCliente,
    required this.lngCliente,
  });
  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapCtrl = MapController();
  Position? _myPos;
  StreamSubscription<Position>? _posStream;
  bool _enCamino = false;
  double _distKm = 0;
  int _minutos = 0;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _marcarEnCamino();
  }

  Future<void> _initLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() {
        _myPos = pos;
        _distKm = LocationService.calculateDistance(pos.latitude, pos.longitude, widget.latCliente, widget.lngCliente);
        _minutos = (_distKm / 30 * 60).round();
      });
      _mapCtrl.move(LatLng(pos.latitude, pos.longitude), 14);
    }
    _posStream = LocationService.getPositionStream().listen((p) {
      if (mounted) {
        setState(() {
          _myPos = p;
          _distKm = LocationService.calculateDistance(p.latitude, p.longitude, widget.latCliente, widget.lngCliente);
          _minutos = (_distKm / 30 * 60).round();
        });
        SocketService.updateLocation(widget.solicitudId, p.latitude, p.longitude);
      }
    });
  }

  Future<void> _marcarEnCamino() async {
    await ApiService.put(ApiConfig.serviceEstado(widget.solicitudId), {'estado': 'en_camino'});
    SocketService.enCamino(widget.solicitudId);
    setState(() => _enCamino = true);
  }

  Future<void> _llegueDestino() async {
    SocketService.llegueDestino(widget.solicitudId);
    await ApiService.put(ApiConfig.serviceEstado(widget.solicitudId), {'estado': 'en_progreso'});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Has llegado al destino! El servicio ha comenzado.'), backgroundColor: AppColors.success));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ServiceSummaryScreen(solicitudId: widget.solicitudId, folio: widget.folio)));
  }

  @override
  void dispose() {
    _posStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myLat = _myPos?.latitude ?? -12.0464;
    final myLng = _myPos?.longitude ?? -77.0428;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Navegación J&P', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('Orden #${widget.folio} • ${_enCamino ? "En camino" : "Preparando"}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {})],
      ),
      body: Stack(
        children: [
          // Mapa OpenStreetMap
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: LatLng(myLat, myLng),
              initialZoom: 14,
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.jp.tech.support'),
              MarkerLayer(markers: [
                // Mi posición
                Marker(
                  point: LatLng(myLat, myLng),
                  width: 40, height: 40,
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)]),
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
                // Destino cliente
                Marker(
                  point: LatLng(widget.latCliente, widget.lngCliente),
                  width: 44, height: 44,
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 22),
                  ),
                ),
              ]),
              PolylineLayer(polylines: [
                Polyline(points: [LatLng(myLat, myLng), LatLng(widget.latCliente, widget.lngCliente)], strokeWidth: 4, color: AppColors.primary.withOpacity(0.7), isDotted: false),
              ]),
            ],
          ),

          // Barra superior dirección
          Positioned(
            top: 12, left: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
              child: Row(children: [
                const Icon(Icons.navigation_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.lngCliente.toString().length > 20 ? '${widget.clienteNombre} - Destino' : 'Av. Javier Prado 1234, San Isidro', style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: AppColors.border),
                const SizedBox(width: 8),
                const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 18),
              ]),
            ),
          ),

          // Controles del mapa
          Positioned(
            right: 12, top: 80,
            child: Column(children: [
              _MapBtn(icon: Icons.add, onTap: () => _mapCtrl.move(_mapCtrl.camera.center, _mapCtrl.camera.zoom + 1)),
              const SizedBox(height: 4),
              _MapBtn(icon: Icons.remove, onTap: () => _mapCtrl.move(_mapCtrl.camera.center, _mapCtrl.camera.zoom - 1)),
              const SizedBox(height: 4),
              _MapBtn(icon: Icons.my_location, onTap: () { if (_myPos != null) _mapCtrl.move(LatLng(_myPos!.latitude, _myPos!.longitude), 15); }),
              const SizedBox(height: 4),
              _MapBtn(icon: Icons.chat_bubble_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(solicitudId: widget.solicitudId, otroNombre: widget.clienteNombre, esTecnico: true)))),
            ]),
          ),

          // Panel inferior
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, spreadRadius: 2)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.clienteNombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(widget.descripcion, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('$_minutos min', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.primary)),
                      Text('${_distKm.toStringAsFixed(1)} km', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ]),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _llegueDestino,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Llegué al destino'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                      child: IconButton(icon: const Icon(Icons.phone_outlined, color: AppColors.primary), onPressed: () {}),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.navigation), label: 'Ruta'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tareas'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (_) {},
      ),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]), child: Icon(icon, size: 20, color: AppColors.primary)),
  );
}
