import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../client/chat_screen.dart';
import '../client/home_screen.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final int solicitudId;
  final String tecnicoNombre;
  const BookingConfirmedScreen({super.key, required this.solicitudId, required this.tecnicoNombre});
  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  Map<String, dynamic>? _solicitud;

  @override
  void initState() {
    super.initState();
    _loadSolicitud();
  }

  Future<void> _loadSolicitud() async {
    final result = await ApiService.get(ApiConfig.serviceById(widget.solicitudId));
    if (result['success'] && mounted) setState(() => _solicitud = result['data']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('J&P Tech Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.check, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('¡Técnico reservado con éxito!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Tu solicitud ha sido confirmada. El especialista llegará en el horario seleccionado.', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 24),

            // Técnico asignado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, size: 30, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TÉCNICO ASIGNADO', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        Text(widget.tecnicoNombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                        Row(children: [
                          ...List.generate(5, (i) => Icon(i < 4 ? Icons.star : Icons.star_half, color: AppColors.star, size: 14)),
                          const SizedBox(width: 4),
                          const Text('4.9 (124 reseñas)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ]),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, children: [
                          _Tag('HARDWARE EXPERT'),
                          _Tag('CERTIFICADO J&P'),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Fecha y hora
            if (_solicitud != null) Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  const Text('FECHA Y HORA', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_solicitud?['fecha_servicio'] ?? 'Por confirmar', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.access_time, color: AppColors.primary, size: 18)),
                    const SizedBox(width: 12),
                    Text('${_solicitud?['horario_inicio'] ?? '14:30'} - ${_solicitud?['horario_fin'] ?? '16:00'}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const Spacer(),
                    const Text('GMT-5', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.build, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estado: Preparando herramientas', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('El técnico está verificando los componentes necesarios para tu reparación.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(solicitudId: widget.solicitudId, otroNombre: widget.tecnicoNombre, esTecnico: false))),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('IR AL CHAT'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
              icon: const Icon(Icons.list),
              label: const Text('VER MIS SERVICIOS'),
            ),
            const SizedBox(height: 16),
            if (_solicitud?['direccion'] != null) Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(child: Text('Servicio programado en: ${_solicitud!['direccion']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
  );
}
