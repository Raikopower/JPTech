import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _correoCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  Future<void> _send() async {
    if (_correoCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    await ApiService.post(ApiConfig.forgotPassword, {'correo': _correoCtrl.text}, withAuth: false);
    setState(() { _loading = false; _sent = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('J&P'), leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(child: Container(width: 70, height: 70, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.lock_reset, color: AppColors.primary, size: 35))),
            const SizedBox(height: 20),
            const Text('Restablecer contraseña', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Ingresa tu correo para recibir un código de recuperación', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            if (!_sent) ...[
              TextFormField(controller: _correoCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined), hintText: 'ejemplo@correo.com')),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loading ? null : _send, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Enviar Código')),
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success)),
                child: const Row(
                  children: [Icon(Icons.check_circle, color: AppColors.success), SizedBox(width: 12), Expanded(child: Text('Código enviado. Revisa tu correo electrónico.'))],
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.arrow_back, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('Volver al inicio de sesión', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
