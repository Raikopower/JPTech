import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import '../../config/api_config.dart';
import 'marketplace_screen.dart';
import 'service_detail_screen.dart';
import '../client/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _disponible = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ServiceProvider>().loadMisSolicitudes());
    SocketService.onNuevaSolicitud((_) { if (mounted) setState(() {}); });
  }

  Future<void> _toggleDisponible(bool val) async {
    setState(() => _disponible = val);
    await ApiService.put(ApiConfig.techAvailability, {'disponible': val});
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();
    final completados = sp.solicitudes.where((s) => s.estado == 'finalizado').length;
    final asignados = sp.solicitudes.where((s) => ['confirmado','en_camino','en_progreso'].contains(s.estado)).length;

    final pages = [
      _buildMain(sp, asignados, completados),
      const _MisTrabajos(),
      const _Billetera(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Marketplace'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Mis Trabajos'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Billetera'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cuenta'),
        ],
      ),
    );
  }

  Widget _buildMain(ServiceProvider sp, int asignados, int completados) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.handyman, color: AppColors.primary, size: 20)),
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('J&P Technician', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          Text('Panel de Control', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        actions: [
          Stack(children: [
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
            Positioned(top: 8, right: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle))),
          ]),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => sp.loadMisSolicitudes(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Disponibilidad
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Estado de Disponibilidad', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(_disponible ? 'Estás recibiendo solicitudes de trabajo' : 'No estás disponible actualmente', style: TextStyle(color: _disponible ? AppColors.success : AppColors.textSecondary, fontSize: 12)),
                  ])),
                  Switch(value: _disponible, onChanged: _toggleDisponible, activeColor: AppColors.primary),
                ]),
              ),
              const SizedBox(height: 14),
              // Stats
              Row(children: [
                Expanded(child: _StatBox(icon: Icons.assignment_outlined, label: 'HOY', value: '$asignados', sublabel: 'TRABAJOS ASIGNADOS', color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _StatBox(icon: Icons.check_circle_outline, label: 'COMPLETADO', value: '$completados', sublabel: 'TAREAS FINALIZADAS', color: AppColors.success)),
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Servicios Asignados', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                TextButton(onPressed: () => setState(() => _selectedIndex = 1), child: const Text('Ver todos', style: TextStyle(color: AppColors.primary))),
              ]),
              const SizedBox(height: 8),
              if (sp.solicitudes.isEmpty)
                Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: const Center(child: Column(children: [Icon(Icons.inbox_outlined, size: 48, color: AppColors.textHint), SizedBox(height: 8), Text('No hay servicios asignados', style: TextStyle(color: AppColors.textSecondary))])))
              else
                ...sp.solicitudes.take(5).map((s) => GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(solicitudId: s.id))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.computer, color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [Expanded(child: Text(s.categoriaNombre ?? 'Servicio', style: const TextStyle(fontWeight: FontWeight.w600))), _EstadoBadge(estado: s.estado)]),
                        Text('Folio: ${s.folio}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text(s.direccion, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                        if (s.horarioInicio != null) Text('${s.horarioInicio} - ${s.horarioFin}', style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                      ])),
                    ]),
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon; final String label, value, sublabel; final Color color;
  const _StatBox({required this.icon, required this.label, required this.value, required this.sublabel, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: color, size: 16), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
      Text(sublabel, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});
  Color get _color { switch (estado) { case 'en_progreso': return AppColors.warning; case 'confirmado': return AppColors.success; case 'en_camino': return AppColors.info; default: return AppColors.textSecondary; } }
  String get _label { switch (estado) { case 'en_progreso': return 'EN PROGRESO'; case 'confirmado': return 'CONFIRMADO'; case 'en_camino': return 'EN CAMINO'; default: return 'PENDIENTE'; } }
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(_label, style: TextStyle(color: _color, fontSize: 9, fontWeight: FontWeight.w800)));
}

class _MisTrabajos extends StatelessWidget {
  const _MisTrabajos();
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Trabajos')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sp.solicitudes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final s = sp.solicitudes[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(solicitudId: s.id))),
            child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text(s.folio, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)), const Spacer(), _EstadoBadge(estado: s.estado)]),
                Text(s.categoriaNombre ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(s.descripcion, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _Billetera extends StatelessWidget {
  const _Billetera();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Billetera')),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet_outlined, size: 40, color: AppColors.primary)),
      const SizedBox(height: 16),
      const Text('S/ 0.00', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
      const Text('Saldo disponible', style: TextStyle(color: AppColors.textSecondary)),
    ])),
  );
}
