import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/service_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'booking_confirmed_screen.dart';

// ── Modelo ficticio para pruebas locales ──────────────────────────
class _MockOferta {
  final int id;
  final String nombre;
  final String especialidad;
  final double calificacion;
  final int resenas;
  final double precio;
  final String experiencia;
  final Color badgeColor;

  const _MockOferta({
    required this.id,
    required this.nombre,
    required this.especialidad,
    required this.calificacion,
    required this.resenas,
    required this.precio,
    required this.experiencia,
    required this.badgeColor,
  });
}

const List<_MockOferta> _mockOfertas = [
  _MockOferta(
    id: 1,
    nombre: 'Carlos Rodríguez',
    especialidad: 'SOPORTE PC',
    calificacion: 4.9,
    resenas: 124,
    precio: 60.00,
    experiencia: '5 años exp.',
    badgeColor: AppColors.primary,
  ),
  _MockOferta(
    id: 2,
    nombre: 'Andrea Torres',
    especialidad: 'SOPORTE PC',
    calificacion: 4.8,
    resenas: 89,
    precio: 55.00,
    experiencia: '3 años exp.',
    badgeColor: AppColors.success,
  ),
  _MockOferta(
    id: 3,
    nombre: 'Miguel Ramos',
    especialidad: 'SOPORTE PC',
    calificacion: 5.0,
    resenas: 52,
    precio: 75.00,
    experiencia: '7 años exp.',
    badgeColor: AppColors.urgMedia,
  ),
  _MockOferta(
    id: 4,
    nombre: 'Elena Vega',
    especialidad: 'SOPORTE PC',
    calificacion: 4.7,
    resenas: 210,
    precio: 45.00,
    experiencia: '4 años exp.',
    badgeColor: AppColors.info,
  ),
];
// ─────────────────────────────────────────────────────────────────

class TechnicianOffersScreen extends StatefulWidget {
  final int solicitudId;
  const TechnicianOffersScreen({super.key, required this.solicitudId});
  @override
  State<TechnicianOffersScreen> createState() => _TechnicianOffersScreenState();
}

class _TechnicianOffersScreenState extends State<TechnicianOffersScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ServiceProvider>().loadOfertas(widget.solicitudId),
    );
  }

  // Seleccionar oferta REAL (viene del backend)
  Future<void> _seleccionarReal(int ofertaId, String nombre) async {
    setState(() => _loading = true);
    final result = await ApiService.post(ApiConfig.acceptOffer(ofertaId), {});
    setState(() => _loading = false);
    if (!mounted) return;
    if (result['success']) {
      _irAConfirmado(nombre);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error']), backgroundColor: AppColors.error),
      );
    }
  }

  // Seleccionar oferta FICTICIA (modo local/demo)
  void _seleccionarMock(String nombre) {
    _irAConfirmado(nombre);
  }

  void _irAConfirmado(String nombre) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmedScreen(
          solicitudId: widget.solicitudId,
          tecnicoNombre: nombre,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();

    // Usa ofertas reales si existen, si no usa las ficticias
    final bool usandoMock = sp.ofertas.isEmpty;
    final int totalOfertas = usandoMock ? _mockOfertas.length : sp.ofertas.length;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('J&P Tech Support'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ofertas Recibidas',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$totalOfertas técnicos especializados están listos para ayudarte.',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          Expanded(
            child: sp.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: totalOfertas,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      if (usandoMock) {
                        return _MockOfertaCard(
                          oferta: _mockOfertas[i],
                          loading: _loading,
                          onSeleccionar: () =>
                              _seleccionarMock(_mockOfertas[i].nombre),
                        );
                      }
                      // Oferta real del backend
                      final o = sp.ofertas[i];
                      return _OfertaCard(
                        nombre:        o.nombre ?? 'Técnico',
                        especialidad:  o.especialidad ?? 'SOPORTE PC',
                        calificacion:  o.calificacionPromedio,
                        resenas:       o.totalResenas,
                        precio:        o.precio,
                        loading:       _loading,
                        onSeleccionar: () =>
                            _seleccionarReal(o.id, o.nombre ?? 'Técnico'),
                      );
                    },
                  ),
          ),

          // Banner seguridad
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seguridad J&P Garantizada',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Todos nuestros técnicos han pasado por un proceso de verificación de identidad y capacidad técnica.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SLA\n99.8%',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Soporte\n24/7',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card para oferta FICTICIA ────────────────────────────────────
class _MockOfertaCard extends StatelessWidget {
  final _MockOferta oferta;
  final bool loading;
  final VoidCallback onSeleccionar;

  const _MockOfertaCard({
    required this.oferta,
    required this.loading,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: oferta.badgeColor.withOpacity(0.15),
                    child: Text(
                      oferta.nombre[0],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: oferta.badgeColor,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.white, blurRadius: 2, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      oferta.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.star, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${oferta.calificacion.toStringAsFixed(1)} (${oferta.resenas})',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          oferta.experiencia,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        oferta.especialidad,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRECIO OFERTA',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'S/. ${oferta.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: loading ? null : onSeleccionar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 44),
                ),
                child: const Text('SELECCIONAR'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Card para oferta REAL del backend ───────────────────────────
class _OfertaCard extends StatelessWidget {
  final String nombre;
  final String especialidad;
  final double calificacion;
  final int resenas;
  final double precio;
  final bool loading;
  final VoidCallback onSeleccionar;

  const _OfertaCard({
    required this.nombre,
    required this.especialidad,
    required this.calificacion,
    required this.resenas,
    required this.precio,
    required this.loading,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 30, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.white, blurRadius: 2, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.star, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${calificacion.toStringAsFixed(1)} ($resenas)',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        especialidad,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRECIO OFERTA',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'S/. ${precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: loading ? null : onSeleccionar,
                style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
                child: const Text('SELECCIONAR'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}