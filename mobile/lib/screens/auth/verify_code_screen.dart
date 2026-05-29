import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'login_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String correo;
  const VerifyCodeScreen({super.key, required this.correo});
  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  String _code = '';
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    if (_code.length < 6) { setState(() => _error = 'Ingresa el código completo'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.post(ApiConfig.verify, {'correo': widget.correo, 'codigo': _code}, withAuth: false);
      if (!mounted) return;
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Cuenta verificada exitosamente!'), backgroundColor: AppColors.success));
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
      } else {
        setState(() => _error = result['error']);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    await ApiService.post(ApiConfig.forgotPassword, {'correo': widget.correo}, withAuth: false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código reenviado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  Container(width: 70, height: 70, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.lock_reset, color: AppColors.primary, size: 35)),
                  const SizedBox(height: 16),
                  const Text('J&P', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  const Text('Verifica tu cuenta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Hemos enviado un código a tu correo', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (v) => setState(() => _code = v),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 52,
                      fieldWidth: 44,
                      activeFillColor: AppColors.surface,
                      selectedFillColor: AppColors.primary.withOpacity(0.1),
                      inactiveFillColor: AppColors.surface,
                      activeColor: AppColors.primary,
                      selectedColor: AppColors.primary,
                      inactiveColor: AppColors.border,
                    ),
                    enableActiveFill: true,
                    keyboardType: TextInputType.number,
                  ),
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _verify,
                    child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Verificar Código'),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _resend,
                    child: const Text.rich(TextSpan(children: [
                      TextSpan(text: '¿No recibiste el código? ', style: TextStyle(color: AppColors.textSecondary)),
                      TextSpan(text: 'Reenviar código', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ])),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text('Volver al inicio de sesión', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
