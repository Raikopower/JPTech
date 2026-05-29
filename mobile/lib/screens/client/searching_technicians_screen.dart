import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'technician_offers_screen.dart';

class SearchingTechniciansScreen extends StatefulWidget {
  final int solicitudId;
  final String folio;
  final String categoriaName;
  final String direccion;

  const SearchingTechniciansScreen({
    super.key,
    required this.solicitudId,
    required this.folio,
    required this.categoriaName,
    required this.direccion,
  });

  @override
  State<SearchingTechniciansScreen> createState() =>
      _SearchingTechniciansScreenState();
}

class _SearchingTechniciansScreenState
    extends State<SearchingTechniciansScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _searchStep = 0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    // Escuchar oferta real por socket
    SocketService.joinSolicitud(widget.solicitudId);
    SocketService.onNuevaOferta((_) {
      if (!mounted) return;
      setState(() => _searchStep = 2);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _irAOfertas();
      });
    });

    // Paso 1 — "Buscando técnicos" se completa a los 2s
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _searchStep = 1);
    });

    // Paso 2 — "Calculando arribo" se completa a los 4s
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _searchStep = 2);
    });

    // FIX: modo local — navega automáticamente a ofertas a los 6s
    // sin necesitar un técnico real conectado
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) _irAOfertas();
    });
  }

  void _irAOfertas() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TechnicianOffersScreen(solicitudId: widget.solicitudId),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SocketService.offEvent('nueva_oferta');
    super.dispose();
  }

  Future<void> _cancelar() async {
    await ApiService.put(
      ApiConfig.serviceEstado(widget.solicitudId),
      {'estado': 'cancelado'},
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancelar,
        ),
        title: const Text(
          'J&P TECH SUPPORT',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animación búsqueda
              AnimatedBuilder(
                animation: _controller,
                builder: (_, child) => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary
                          .withOpacity(0.3 + 0.7 * _controller.value),
                      width: 3,
                    ),
                  ),
                  child: child,
                ),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.search, size: 48, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Estamos notificando a los técnicos certificados cerca de ti...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Esto puede tomar unos segundos',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Ubicación y servicio
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'UBICACIÓN',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lima, Perú',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'SERVICIO',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.categoriaName,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Steps
              _StepItem(
                text: 'Buscando técnicos disponibles...',
                done: _searchStep >= 1,
                active: _searchStep == 0,
              ),
              const SizedBox(height: 8),
              _StepItem(
                text: 'Calculando tiempo de arribo',
                done: _searchStep >= 2,
                active: _searchStep == 1,
              ),
              const SizedBox(height: 32),

              const Text(
                'Nuestros especialistas están certificados bajo los estándares de ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const Text(
                'J&P Tech Precision™',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              TextButton.icon(
                onPressed: _cancelar,
                icon: const Icon(Icons.arrow_forward, color: AppColors.error),
                label: const Text(
                  'CANCELAR SOLICITUD',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String text;
  final bool done;
  final bool active;

  const _StepItem({
    required this.text,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done
                  ? AppColors.success
                  : (active ? AppColors.primary : AppColors.border),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}