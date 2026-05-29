import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/app_colors.dart';
import '../../providers/service_provider.dart';
import '../../services/location_service.dart';
import 'schedule_screen.dart';

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});
  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _descCtrl = TextEditingController();

  // FIX 1: valor del dropdown = id (string) — evita crash con nombres duplicados
  String? _dropdownValue;
  String? _categoriaSeleccionada;
  int?    _categoriaId;

  String    _urgencia = 'media';
  File?     _imagen;
  Position? _position;
  String    _direccion = '';
  bool      _loadingLocation = false;

  // FIX 2: corrige doble-encoding MySQL (ó→├│, é→├® etc.)
  String _fix(String? t) {
    if (t == null || t.isEmpty) return '';
    try { return utf8.decode(latin1.encode(t)); } catch (_) { return t; }
  }

  @override
  void initState() {
    super.initState();
    context.read<ServiceProvider>().loadCategorias();
    _getLocation();
  }

  @override
  void dispose() { _descCtrl.dispose(); super.dispose(); }

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    final pos = await LocationService.getCurrentPosition();
    setState(() {
      _position = pos;
      _loadingLocation = false;
      if (pos != null) _direccion = 'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
    });
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _imagen = File(img.path));
  }

  void _continuar() {
    if (_categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una categoría')));
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Describe el problema')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleScreen(
      categoriaId:   _categoriaId!,
      categoriaName: _categoriaSeleccionada!,
      descripcion:   _descCtrl.text.trim(),
      urgencia:      _urgencia,
      // FIX 3: fallback Lima si no hay GPS
      direccion:     _direccion.isNotEmpty ? _direccion : 'Lima, Perú',
      latitud:       _position?.latitude,
      longitud:      _position?.longitude,
      imagen:        _imagen,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();
    // FIX 4: deduplica por ID antes de construir items del dropdown
    final seen = <int>{};
    final cats = sp.categorias.where((c) => seen.add(c.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('J&P'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(children: [
              const Text('Detalles del Servicio', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text('PASO 1 DE 3', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: 0.33, backgroundColor: AppColors.border, color: AppColors.primary, minHeight: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CATEGORÍA DE SOPORTE TI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  // FIX PRINCIPAL: usa ID como valor, no nombre
                  DropdownButtonFormField<String>(
                    value: _dropdownValue,
                    decoration: const InputDecoration(hintText: 'Seleccione una categoría'),
                    items: cats.map((c) => DropdownMenuItem<String>(
                      value: c.id.toString(),
                      child: Text(_fix(c.nombre)),
                    )).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final cat = cats.firstWhere((c) => c.id.toString() == v);
                      setState(() {
                        _dropdownValue         = v;
                        _categoriaId           = cat.id;
                        _categoriaSeleccionada = _fix(cat.nombre);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('DESCRIPCIÓN DEL PROBLEMA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Describa el problema en detalle (ej: La impresora no conecta al Wi-Fi, la laptop se calienta...)'),
                  ),
                  const SizedBox(height: 20),
                  const Text('NIVEL DE URGENCIA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['baja', 'media', 'alta'].map((u) {
                      final sel = _urgencia == u;
                      return Expanded(child: GestureDetector(
                        onTap: () => setState(() => _urgencia = u),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: sel ? 2 : 1),
                            borderRadius: BorderRadius.circular(8),
                            color: sel ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                          ),
                          child: Text(u.toUpperCase(), textAlign: TextAlign.center,
                              style: TextStyle(color: sel ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ));
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('SUBIR FOTO/VIDEO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 100, width: double.infinity,
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: _imagen != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imagen!, fit: BoxFit.cover))
                          : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.textSecondary),
                              SizedBox(height: 8),
                              Text('Agregar archivos o tomar foto', style: TextStyle(color: AppColors.textSecondary)),
                              Text('PNG, JPG, MP4 hasta 50MB', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                            ]),
                    ),
                  ),
                  // Indicador GPS
                  if (_loadingLocation)
                    const Padding(padding: EdgeInsets.only(top: 12),
                        child: Row(children: [
                          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Obteniendo ubicación...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ])),
                  if (!_loadingLocation && _direccion.isNotEmpty)
                    Padding(padding: const EdgeInsets.only(top: 12),
                        child: Row(children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(child: Text(_direccion, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ])),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              ElevatedButton.icon(onPressed: _continuar, icon: const Icon(Icons.search), label: const Text('Buscar Técnicos')),
              const SizedBox(height: 8),
              const Text('Al continuar, acepta nuestros Términos de Servicio.', style: TextStyle(color: AppColors.textHint, fontSize: 12), textAlign: TextAlign.center),
            ]),
          ),
        ],
      ),
    );
  }
}
