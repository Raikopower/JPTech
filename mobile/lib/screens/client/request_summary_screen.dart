import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/service_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'searching_technicians_screen.dart';

class RequestSummaryScreen extends StatefulWidget {
  final int categoriaId;
  final String categoriaName;
  final String descripcion;
  final String urgencia;
  final String direccion;
  final double? latitud;
  final double? longitud;
  final DateTime fecha;
  final String horarioInicio;
  final String horarioFin;
  final File? imagen;

  const RequestSummaryScreen({
    super.key,
    required this.categoriaId,
    required this.categoriaName,
    required this.descripcion,
    required this.urgencia,
    required this.direccion,
    this.latitud,
    this.longitud,
    required this.fecha,
    required this.horarioInicio,
    required this.horarioFin,
    this.imagen,
  });

  @override
  State<RequestSummaryScreen> createState() => _RequestSummaryScreenState();
}

class _RequestSummaryScreenState extends State<RequestSummaryScreen> {
  bool _loading = false;

  // FIX: dirección con fallback para emulador sin GPS
  String get _direccionFinal =>
      widget.direccion.isNotEmpty
          ? widget.direccion
          : 'Lima, Perú';

  // FIX: latitud/longitud con fallback a Lima, Perú
  double get _latFinal => widget.latitud ?? -12.0464;
  double get _lngFinal => widget.longitud ?? -77.0428;

  Color get _urgColor =>
      widget.urgencia == 'alta'
          ? AppColors.urgAlta
          : widget.urgencia == 'media'
              ? AppColors.urgMedia
              : AppColors.urgBaja;

  Future<void> _enviar() async {
    setState(() => _loading = true);
    try {
      final fields = {
        'categoria_id':   widget.categoriaId.toString(),
        'descripcion':    widget.descripcion,
        'urgencia':       widget.urgencia,
        'fecha_servicio': DateFormat('yyyy-MM-dd').format(widget.fecha),
        'horario_inicio': widget.horarioInicio,
        'horario_fin':    widget.horarioFin,
        // FIX: siempre envía una dirección, nunca vacío
        'direccion':      _direccionFinal,
        // FIX: siempre envía lat/lng, usa Lima como fallback
        'latitud':        _latFinal.toString(),
        'longitud':       _lngFinal.toString(),
      };

      final result = await ApiService.multipartPost(
        ApiConfig.services,
        fields,
        file: widget.imagen,
      );

      if (!mounted) return;

      if (result['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SearchingTechniciansScreen(
              solicitudId: result['data']['solicitud_id'],
              folio:       result['data']['folio'],
              categoriaName: widget.categoriaName,
              direccion:   _direccionFinal,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al enviar solicitud'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('J&P Tech Support'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Resumen Final',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PASO 3 DE 3',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Confirmar Solicitud',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const Text(
                    'Por favor, revisa que toda la información técnica sea correcta antes de enviar.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // ── SERVICIO ──
                  _SectionCard(
                    icon: Icons.computer,
                    title: 'SERVICIO',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categoría',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        Text(
                          widget.categoriaName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'PRIORIDAD',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _urgColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 8, color: _urgColor),
                              const SizedBox(width: 6),
                              Text(
                                widget.urgencia.toUpperCase(),
                                style: TextStyle(
                                  color: _urgColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── PROGRAMACIÓN ──
                  _SectionCard(
                    icon: Icons.calendar_today,
                    title: 'PROGRAMACIÓN',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fecha',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        Text(
                          DateFormat("dd 'de' MMMM, yyyy", 'es').format(widget.fecha),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Horario Estimado',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        Text(
                          '${widget.horarioInicio} - ${widget.horarioFin} hrs',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── DETALLE DEL PROBLEMA ──
                  _SectionCard(
                    icon: Icons.description_outlined,
                    title: 'DETALLE DEL PROBLEMA',
                    child: Text(
                      '"${widget.descripcion}"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── UBICACIÓN ──
                  _SectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'UBICACIÓN',
                    // FIX: evita crash si direccion está vacía
                    trailing: Text(
                      _direccionFinal.contains(',')
                          ? _direccionFinal.split(',').first
                          : _direccionFinal,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map, size: 48, color: AppColors.primary),
                                Text(
                                  'Vista del mapa',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.home_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _direccionFinal,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── BOTONES ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : _enviar,
                  icon: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: const Text('ENVIAR SOLICITUD'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('EDITAR DATOS'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}