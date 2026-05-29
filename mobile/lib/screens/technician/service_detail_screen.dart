import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'navigation_screen.dart';
import '../client/chat_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int solicitudId;
  const ServiceDetailScreen({super.key, required this.solicitudId});
  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiService.get(ApiConfig.serviceById(widget.solicitudId));
    if (r['success'] && mounted) setState(() { _data = r['data']; _loading = false; });
    else setState(() => _loading = false);
  }

  Color _urgColor(String u) => u == 'alta' ? AppColors.urgAlta : u == 'media' ? AppColors.urgMedia : AppColors.urgBaja;

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Detalle de Servicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text(d != null ? 'Folio: ${d['folio']}' : '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : d == null ? const Center(child: Text('Error cargando servicio'))
          : Column(
              children: [
                // Estado banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppColors.primary.withOpacity(0.07),
                  child: Row(children: [
                    const Icon(Icons.build_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    const Text('Pendiente de Inicio', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: _urgColor(d['urgencia'] ?? 'media').withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text('URGENCIA ${(d['urgencia'] ?? 'media').toUpperCase()}', style: TextStyle(color: _urgColor(d['urgencia'] ?? 'media'), fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('INFORMACIÓN DEL CLIENTE', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                          child: Row(children: [
                            CircleAvatar(radius: 28, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, color: AppColors.primary, size: 28)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(d['cliente_nombre'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              const Text('Cliente Residencial Gold', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)), child: Text('ID: ${d['cliente_id']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                            ])),
                          ]),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                          child: Row(children: [
                            const Icon(Icons.map_outlined, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Dirección de Servicio', style: TextStyle(fontWeight: FontWeight.w700)),
                              Text(d['direccion'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              const Text('A 2.4 km de tu ubicación actual', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ])),
                          ]),
                        ),
                        const SizedBox(height: 14),
                        const Text('DETALLES DEL TRABAJO', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('CATEGORÍA', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              const Icon(Icons.computer_outlined, color: AppColors.primary, size: 20),
                              const SizedBox(height: 4),
                              Text(d['categoria_nombre'] ?? 'Soporte Técnico', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ]),
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('PRIORIDAD', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Icon(Icons.priority_high, color: _urgColor(d['urgencia'] ?? 'media'), size: 20),
                              const SizedBox(height: 4),
                              Text((d['urgencia'] ?? 'Media').toString().capitalize, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _urgColor(d['urgencia'] ?? 'media'))),
                            ]),
                          )),
                        ]),
                        const SizedBox(height: 12),
                        const Text('Descripción del problema', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.urgAlta.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border(left: BorderSide(color: AppColors.urgAlta, width: 3))),
                          child: Text('"${d['descripcion']}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14)),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // Botones de acción
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NavigationScreen(
                        solicitudId: widget.solicitudId,
                        folio: d['folio'],
                        clienteNombre: d['cliente_nombre'] ?? '',
                        descripcion: d['descripcion'] ?? '',
                        latCliente: d['latitud_cliente'] != null ? double.parse(d['latitud_cliente'].toString()) : -12.0976,
                        lngCliente: d['longitud_cliente'] != null ? double.parse(d['longitud_cliente'].toString()) : -77.0531,
                      ))),
                      icon: const Icon(Icons.navigation),
                      label: const Text('Iniciar Navegación'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(solicitudId: widget.solicitudId, otroNombre: d['cliente_nombre'] ?? 'Cliente', esTecnico: true))),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Contactar Cliente'),
                    ),
                    const SizedBox(height: 8),
                    // Mini mapa decorativo
                    Container(height: 80, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.07), borderRadius: BorderRadius.circular(12)), child: const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.map, color: AppColors.primary), SizedBox(width: 8), Text('Ver en mapa', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))]))),
                  ]),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (_) {},
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
