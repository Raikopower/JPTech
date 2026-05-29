import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'service_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<dynamic> _leads = [];
  bool _loading = true;
  String _categoriaFiltro = 'Todos';
  final _searchCtrl = TextEditingController();

  final List<String> _categorias = ['Todos', 'Laptops', 'PCs', 'Impresoras', 'Redes', 'Servidores'];

  @override
  void initState() { super.initState(); _loadLeads(); }

  Future<void> _loadLeads() async {
    setState(() => _loading = true);
    final r = await ApiService.get('${ApiConfig.marketplace}?categoria=${_categoriaFiltro == "Todos" ? "" : _categoriaFiltro}');
    setState(() { _leads = r['success'] ? (r['data'] as List) : []; _loading = false; });
  }

  Future<void> _desbloquear(dynamic lead) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Desbloquear Lead'),
        content: Text('¿Deseas desbloquear este lead por S/. ${lead['precio_lead']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Desbloquear')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(solicitudId: lead['solicitud_id'])));
  }

  Color _urgColor(String u) => u == 'alta' ? AppColors.urgAlta : u == 'media' ? AppColors.urgMedia : AppColors.urgBaja;
  IconData _catIcon(String cat) {
    if (cat.contains('Laptop')) return Icons.laptop;
    if (cat.contains('PC') || cat.contains('PC') || cat.contains('Soporte')) return Icons.computer;
    if (cat.contains('Impres')) return Icons.print;
    if (cat.contains('Red')) return Icons.wifi;
    return Icons.build;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.store_outlined, color: AppColors.primary, size: 20)),
        title: const Text('J&P Marketplace', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Barra búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por zona o servicio',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),

          // Filtros categoría
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categorias.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = _categorias[i];
                final sel = _categoriaFiltro == c;
                return GestureDetector(
                  onTap: () { setState(() => _categoriaFiltro = c); _loadLeads(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                    ),
                    child: Row(children: [
                      if (c != 'Todos') ...[Icon(_catIcon(c), size: 14, color: sel ? Colors.white : AppColors.textSecondary), const SizedBox(width: 4)],
                      Text(c, style: TextStyle(color: sel ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Header lista
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              Text('Leads Disponibles (${_leads.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.location_on, size: 12, color: AppColors.primary), SizedBox(width: 4), Text('Cerca de ti', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700))])),
            ]),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _leads.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadLeads,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _leads.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            if (i == _leads.length) return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: TextButton(onPressed: _loadLeads, child: const Text('Ver más leads', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)))),
                            );
                            final lead = _leads[i];
                            final urgencia = lead['urgencia'] ?? 'media';
                            final cUrgColor = _urgColor(urgencia);
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: cUrgColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                                        child: Row(children: [
                                          if (urgencia == 'alta') const Text('❗', style: TextStyle(fontSize: 12))
                                          else if (urgencia == 'media') const Text('⚠️', style: TextStyle(fontSize: 12))
                                          else const Text('ℹ️', style: TextStyle(fontSize: 12)),
                                          const SizedBox(width: 4),
                                          Text('URGENCIA ${urgencia.toUpperCase()}', style: TextStyle(color: cUrgColor, fontWeight: FontWeight.w800, fontSize: 11)),
                                        ]),
                                      ),
                                      const Spacer(),
                                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                        const Text('COSTO', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                                        Text('S/. ${lead['precio_lead']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
                                      ]),
                                      const Text(' CR', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(lead['descripcion'] ?? lead['categoria_nombre'] ?? 'Servicio técnico', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                    Text(' A ${lead['distancia_km'] != null ? double.parse(lead['distancia_km'].toString()).toStringAsFixed(1) : '?'} km ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                                    Text(' Publicado hace ${_timeAgo(lead['solicitud_fecha'])}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ]),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)), child: Row(children: [Icon(_catIcon(lead['categoria_nombre'] ?? ''), size: 14, color: AppColors.textSecondary), const SizedBox(width: 4), Text(lead['categoria_nombre'] ?? 'Servicio', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))])),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: () => _desbloquear(lead),
                                      style: ElevatedButton.styleFrom(minimumSize: const Size(130, 38), padding: const EdgeInsets.symmetric(horizontal: 16)),
                                      child: const Text('Desbloquear Lead', style: TextStyle(fontSize: 13)),
                                    ),
                                  ]),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle), child: const Icon(Icons.store_outlined, size: 40, color: AppColors.primary)),
    const SizedBox(height: 16),
    const Text('No hay leads disponibles', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
    const Text('Los nuevos leads aparecerán aquí', style: TextStyle(color: AppColors.textSecondary)),
    const SizedBox(height: 16),
    ElevatedButton(onPressed: _loadLeads, child: const Text('Actualizar')),
  ]));

  String _timeAgo(dynamic fecha) {
    if (fecha == null) return 'hace un momento';
    final d = DateTime.tryParse(fecha.toString());
    if (d == null) return 'hace un momento';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
