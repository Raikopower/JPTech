import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../models/service_model.dart';
import 'service_request_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'rate_service_screen.dart';

// Función global de fix de encoding (reutilizada en todos los widgets)
String _fixEnc(String? text) {
  if (text == null || text.isEmpty) return '';
  try { return utf8.decode(latin1.encode(text)); } catch (_) { return text; }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeContent(),
      const _SearchContent(),
      _ServicesContent(onIr: (i) => setState(() => _selectedIndex = i)),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), activeIcon: Icon(Icons.build_circle), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ─── TAB 0: HOME ─────────────────────────────────────────────────
class _HomeContent extends StatefulWidget {
  const _HomeContent();
  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ServiceProvider>().loadCategorias());
  }

  void _irSolicitar() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const ServiceRequestScreen()));

  void _verNotificaciones() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          const Icon(Icons.notifications_none, size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text('No tienes notificaciones nuevas', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();
    // Deduplicar categorías por ID
    final seen = <int>{};
    final cats = sp.categorias.where((c) => seen.add(c.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('J&P Corporate Systems', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: _verNotificaciones),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => sp.loadCategorias(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de búsqueda
              GestureDetector(
                onTap: _irSolicitar,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: const Row(children: [
                    Icon(Icons.search, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('¿Qué servicio técnico buscas?', style: TextStyle(color: AppColors.textHint)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('20% de descuento', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    const Text('En tu primer Soporte Remoto', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _irSolicitar,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: const Text('SOLICITAR AHORA', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Especialidades
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Especialidades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  TextButton(onPressed: _irSolicitar, child: const Text('Ver todas', style: TextStyle(color: AppColors.primary))),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: cats.isEmpty
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: cats.length > 6 ? 6 : cats.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _CategoriaItem(categoria: cats[i], onTap: _irSolicitar),
                      ),
              ),
              const SizedBox(height: 20),

              // Técnicos
              const Text('Expertos Certificados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _TechCard(index: i, onTap: _irSolicitar),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irSolicitar,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Solicitar Servicio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _CategoriaItem extends StatelessWidget {
  final CategoriaModel categoria;
  final VoidCallback onTap;
  const _CategoriaItem({required this.categoria, required this.onTap});

  IconData _icon() {
    switch (categoria.icono) {
      case 'computer': return Icons.computer;
      case 'laptop':   return Icons.laptop;
      case 'print':    return Icons.print;
      case 'wifi':     return Icons.wifi;
      case 'dns':      return Icons.dns;
      case 'code':     return Icons.code;
      case 'security': return Icons.security;
      default:         return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(_icon(), color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 6),
          Text(_fixEnc(categoria.nombre),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _TechCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;
  const _TechCard({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final names   = ['Ricardo Huamán', 'Andrea Mendoza', 'Carlos López'];
    final specs   = ['Soporte PC', 'Networking', 'Laptops'];
    final prices  = ['S/ 50', 'S/ 80', 'S/ 60'];
    final ratings = [4.9, 4.8, 4.7];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: const Center(child: Icon(Icons.person, size: 50, color: AppColors.primary)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(specs[index], style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 4),
                Text(names[index], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Row(children: [
                  const Icon(Icons.star, color: AppColors.star, size: 11),
                  const SizedBox(width: 2),
                  Text('${ratings[index]}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ]),
                Text('Desde ${prices[index]} por visita', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TAB 1: BUSCAR ────────────────────────────────────────────────
class _SearchContent extends StatelessWidget {
  const _SearchContent();

  IconData _catIcon(String? icono) {
    switch (icono) {
      case 'computer': return Icons.computer;
      case 'laptop':   return Icons.laptop;
      case 'print':    return Icons.print;
      case 'wifi':     return Icons.wifi;
      case 'dns':      return Icons.dns;
      case 'code':     return Icons.code;
      case 'security': return Icons.security;
      default:         return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();
    final seen = <int>{};
    final cats = sp.categorias.where((c) => seen.add(c.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Buscar Técnico')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceRequestScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary, width: 1.5)),
                child: const Row(children: [
                  Icon(Icons.search, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text('Buscar por tipo de servicio...', style: TextStyle(color: AppColors.textHint)),
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text('Categorías de Servicio', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: cats.isEmpty
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4),
                    itemCount: cats.length,
                    itemBuilder: (_, i) {
                      final cat    = cats[i];
                      final nombre = _fixEnc(cat.nombre);
                      final desc   = _fixEnc(cat.descripcion);
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceRequestScreen())),
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(_catIcon(cat.icono), color: AppColors.primary, size: 24),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              if (desc.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── TAB 2: SERVICIOS ─────────────────────────────────────────────
class _ServicesContent extends StatefulWidget {
  final Function(int) onIr;
  const _ServicesContent({required this.onIr});
  @override
  State<_ServicesContent> createState() => _ServicesContentState();
}

class _ServicesContentState extends State<_ServicesContent> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ServiceProvider>().loadMisSolicitudes());
  }

  Color _estadoColor(String e) {
    switch (e) {
      case 'confirmado':  return AppColors.success;
      case 'en_camino':   return AppColors.info;
      case 'en_progreso': return AppColors.warning;
      case 'finalizado':  return AppColors.textSecondary;
      case 'cancelado':   return AppColors.error;
      default:            return AppColors.urgMedia;
    }
  }

  String _estadoLabel(String e) {
    switch (e) {
      case 'confirmado':  return 'CONFIRMADO';
      case 'en_camino':   return 'EN CAMINO';
      case 'en_progreso': return 'EN PROGRESO';
      case 'finalizado':  return 'FINALIZADO';
      case 'cancelado':   return 'CANCELADO';
      case 'buscando':    return 'BUSCANDO';
      case 'ofertando':   return 'OFERTAS';
      default:            return e.toUpperCase();
    }
  }

  void _abrirServicio(SolicitudModel s) {
    if (s.estado == 'finalizado') {
      _opcionesFinalizados(s);
    } else if (['confirmado', 'en_camino', 'en_progreso'].contains(s.estado) && s.tecnicoId != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(solicitudId: s.id, otroNombre: s.tecnicoNombre ?? 'Técnico', esTecnico: false)));
    } else {
      _infoSolicitud(s);
    }
  }

  void _opcionesFinalizados(SolicitudModel s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(s.folio, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(s.categoriaNombre ?? 'Servicio técnico', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          if (s.precioFinal != null) ...[
            const SizedBox(height: 4),
            Text('Total: S/. ${s.precioFinal!.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
          ],
          const SizedBox(height: 20),
          if (s.tecnicoId != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => RateServiceScreen(
                  solicitudId:   s.id,
                  tecnicoId:     s.tecnicoId!,
                  tecnicoNombre: s.tecnicoNombre ?? 'Técnico',
                  categoriaName: s.categoriaNombre ?? 'Servicio',
                  folio:         s.folio,
                )));
              },
              icon: const Icon(Icons.star_outline),
              label: const Text('Calificar Servicio'),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              if (s.tecnicoId != null)
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(solicitudId: s.id, otroNombre: s.tecnicoNombre ?? 'Técnico', esTecnico: false)));
            },
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Ver Chat'),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _infoSolicitud(SolicitudModel s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Text(s.folio, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _estadoColor(s.estado).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(_estadoLabel(s.estado), style: TextStyle(color: _estadoColor(s.estado), fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(s.categoriaNombre ?? 'Servicio técnico', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Text(s.descripcion, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          const Text('Tu solicitud está siendo procesada. Recibirás ofertas pronto.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => sp.loadMisSolicitudes())],
      ),
      body: sp.loading
          ? const Center(child: CircularProgressIndicator())
          : sp.solicitudes.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.build_circle_outlined, size: 80, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text('No tienes servicios aún', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Solicita tu primer servicio técnico', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceRequestScreen())),
                    icon: const Icon(Icons.add), label: const Text('Solicitar Servicio'),
                  ),
                ]))
              : RefreshIndicator(
                  onRefresh: () => sp.loadMisSolicitudes(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: sp.solicitudes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final s = sp.solicitudes[i];
                      final isActive     = ['confirmado', 'en_camino', 'en_progreso'].contains(s.estado);
                      final isFinalizado = s.estado == 'finalizado';
                      return GestureDetector(
                        onTap: () => _abrirServicio(s),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isActive ? AppColors.primary.withOpacity(0.4) : AppColors.border, width: isActive ? 1.5 : 1),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(s.folio, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: _estadoColor(s.estado).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text(_estadoLabel(s.estado), style: TextStyle(color: _estadoColor(s.estado), fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                            ]),
                            const SizedBox(height: 6),
                            Text(s.categoriaNombre ?? 'Servicio técnico', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(s.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            if (s.tecnicoNombre != null) ...[
                              const SizedBox(height: 6),
                              Row(children: [const Icon(Icons.person, size: 14, color: AppColors.primary), const SizedBox(width: 4), Text('Técnico: ${s.tecnicoNombre}', style: const TextStyle(fontSize: 13, color: AppColors.primary))]),
                            ],
                            const SizedBox(height: 10),
                            if (isActive)
                              SizedBox(width: double.infinity, child: OutlinedButton.icon(
                                onPressed: () => _abrirServicio(s),
                                icon: const Icon(Icons.chat_outlined, size: 16),
                                label: const Text('Ir al Chat', style: TextStyle(fontSize: 13)),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                              )),
                            if (isFinalizado)
                              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                                onPressed: () => _abrirServicio(s),
                                icon: const Icon(Icons.star_outline, size: 16),
                                label: const Text('Calificar Servicio', style: TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                              )),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceRequestScreen())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Servicio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
