import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'verify_code_screen.dart';

class RegisterTechnicianScreen extends StatefulWidget {
  const RegisterTechnicianScreen({super.key});
  @override
  State<RegisterTechnicianScreen> createState() => _RegisterTechnicianScreenState();
}

class _RegisterTechnicianScreenState extends State<RegisterTechnicianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _especialidad;
  File? _certFile;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  final List<String> _especialidades = [
    'Soporte PC', 'Laptops', 'Impresoras', 'Redes', 'Servidores', 'Software', 'Virus/Malware'
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
    if (result != null) setState(() => _certFile = File(result.files.single.path!));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final fields = {
        'nombre': _nombreCtrl.text.trim(),
        'correo': _correoCtrl.text.trim(),
        'especialidad': _especialidad ?? '',
        'anios_experiencia': _expCtrl.text,
        'password': _passCtrl.text,
      };
      final result = await ApiService.multipartPost(ApiConfig.registerTecnico, fields, file: _certFile, fileField: 'certificacion');
      if (!mounted) return;
      if (result['success']) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => VerifyCodeScreen(correo: _correoCtrl.text.trim())));
      } else {
        setState(() => _error = result['error']);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Técnico')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Perfil Profesional', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const Text('Únete a J&P como técnico certificado.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo', hintText: 'Juan Pérez'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _correoCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo Electrónico', hintText: 'ejemplo@jp.com'), validator: (v) => !v!.contains('@') ? 'Correo inválido' : null),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _especialidad,
                    decoration: const InputDecoration(labelText: 'Especialidad'),
                    hint: const Text('Selecciona tu oficio'),
                    items: _especialidades.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _especialidad = v),
                    validator: (v) => v == null ? 'Selecciona una especialidad' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _expCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Años de Experiencia', hintText: 'Ej: 5')),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)),
                    ),
                    validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text('Documentación', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.primary.withOpacity(0.05),
                      ),
                      child: Column(
                        children: [
                          Icon(_certFile != null ? Icons.check_circle : Icons.upload_file, color: AppColors.primary, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            _certFile != null ? _certFile!.path.split('/').last : 'Subir Certificación / Título',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          if (_certFile == null) const Text('Formatos permitidos: PDF, JPG, PNG (Máx 5MB)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) ...[
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _register,
                    icon: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.arrow_forward),
                    label: const Text('Registrarme como Técnico'),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text.rich(TextSpan(children: [
                        TextSpan(text: '¿Ya tienes cuenta? ', style: TextStyle(color: AppColors.textSecondary)),
                        TextSpan(text: 'Inicia Sesión', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ])),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(child: Text('J&P PROFESSIONALS', style: TextStyle(color: AppColors.textHint, fontSize: 12, letterSpacing: 1.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
