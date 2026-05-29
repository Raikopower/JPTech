import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dashboard_screen.dart';

class ServiceSummaryScreen extends StatefulWidget {
  final int solicitudId;
  final String folio;
  const ServiceSummaryScreen({super.key, required this.solicitudId, required this.folio});
  @override
  State<ServiceSummaryScreen> createState() => _ServiceSummaryScreenState();
}

class _ServiceSummaryScreenState extends State<ServiceSummaryScreen> {
  final _resumenCtrl = TextEditingController();
  final _materialesCtrl = TextEditingController();
  final _precioCtrl = TextEditingController(text: '0.00');
  File? _fotoTrabajo;
  bool _loading = false;
  Map<String, dynamic>? _tecnico;

  @override
  void initState() {
    super.initState();
    _loadTecnico();
  }

  Future<void> _loadTecnico() async {
    final r = await ApiService.get(ApiConfig.profile);
    if (r['success'] && mounted) setState(() => _tecnico = r['data']);
  }

  Future<void> _pickFoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if (img != null) setState(() => _fotoTrabajo = File(img.path));
  }

  Future<void> _finalizar() async {
    if (_resumenCtrl.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa el resumen del trabajo'))); return; }
    setState(() => _loading = true);
    final fields = {
      'resumen_trabajo': _resumenCtrl.text,
      'materiales_usados': _materialesCtrl.text,
      'precio_final': _precioCtrl.text,
    };
    final result = await ApiService.multipartPost(ApiConfig.serviceFinalizar(widget.solicitudId), fields, file: _fotoTrabajo, fileField: 'imagen_trabajo');
    setState(() => _loading = false);
    if (!mounted) return;
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Servicio finalizado exitosamente!'), backgroundColor: AppColors.success));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardScreen()), (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error']), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Resumen de Servicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('ORDEN #${widget.folio}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Técnico asignado
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.07), borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.handyman, color: Colors.white)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Técnico asignado', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
                        Text(_tecnico?['nombre'] ?? 'Técnico', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  Row(children: [const Icon(Icons.description_outlined, color: AppColors.primary, size: 20), const SizedBox(width: 8), const Text('Detalles del Trabajo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))]),
                  const SizedBox(height: 14),

                  const Text('Resumen del trabajo realizado', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _resumenCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Mantenimiento preventivo, limpieza de ventiladores, cambio de pasta térmica...'),
                  ),
                  const SizedBox(height: 14),

                  const Text('Materiales y repuestos', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _materialesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Pasta térmica Arctic Silver, ventilador CPU compatible...'),
                  ),
                  const SizedBox(height: 14),

                  const Text('Evidencia del trabajo (Foto)', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickFoto,
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: _fotoTrabajo != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_fotoTrabajo!, fit: BoxFit.cover))
                          : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.textSecondary),
                              SizedBox(height: 6),
                              Text('Subir foto del trabajo finalizado', style: TextStyle(color: AppColors.textSecondary)),
                            ]),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('Precio final del servicio', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _precioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.payments_outlined),
                      suffixText: 'S/.',
                      suffixStyle: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success.withOpacity(0.3))),
                    child: Row(children: [
                      const Icon(Icons.info_outline, color: AppColors.success, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('Al finalizar, el sistema generará automáticamente la factura y se enviará al correo electrónico registrado del cliente.', style: TextStyle(fontSize: 12, color: AppColors.textPrimary))),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _finalizar,
              icon: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline),
              label: const Text('Finalizar y Cobrar'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('J&P SERVICIOS TÉCNICOS © 2024', style: TextStyle(color: AppColors.textHint, fontSize: 11, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}
