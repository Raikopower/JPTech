import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'home_screen.dart';

class RateServiceScreen extends StatefulWidget {
  final int solicitudId;
  final int tecnicoId;
  final String tecnicoNombre;
  final String categoriaName;
  final String folio;
  const RateServiceScreen({super.key, required this.solicitudId, required this.tecnicoId, required this.tecnicoNombre, required this.categoriaName, required this.folio});
  @override
  State<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends State<RateServiceScreen> {
  double _rating = 4.0;
  final _commentCtrl = TextEditingController();
  final List<String> _allTags = ['A tiempo', 'Profesional', 'Área limpia', 'Rápido', 'Amable', 'Experto'];
  final List<String> _selectedTags = [];
  bool _loading = false;

  Future<void> _enviar() async {
    setState(() => _loading = true);
    final result = await ApiService.post(ApiConfig.ratings, {
      'solicitud_id': widget.solicitudId,
      'calificacion': _rating.round(),
      'comentario': _commentCtrl.text,
      'tags': _selectedTags,
    });
    setState(() => _loading = false);
    if (!mounted) return;
    if (result['success']) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error']), backgroundColor: AppColors.error));
    }
  }

  String _ratingLabel() {
    if (_rating >= 5) return 'Excelente (5.0)';
    if (_rating >= 4) return 'Muy Bueno (${_rating.toStringAsFixed(1)})';
    if (_rating >= 3) return 'Bueno (${_rating.toStringAsFixed(1)})';
    if (_rating >= 2) return 'Regular (${_rating.toStringAsFixed(1)})';
    return 'Malo (${_rating.toStringAsFixed(1)})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Image.asset('assets/icons/logo.png', height: 32, errorBuilder: (_, __, ___) => const Icon(Icons.handyman, color: AppColors.primary, size: 28)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con foto del técnico
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(radius: 44, backgroundColor: AppColors.primary.withOpacity(0.12), child: const Icon(Icons.person, size: 50, color: AppColors.primary)),
                      Positioned(bottom: 2, right: 2, child: Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white, blurRadius: 2, spreadRadius: 1)]))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('¡Gracias!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('¿Cómo fue tu servicio con ${widget.tecnicoNombre}?', style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                    child: Text('${widget.categoriaName} • Job #${widget.folio}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Text('PRESIONA PARA CALIFICAR', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1))),
                  const SizedBox(height: 12),
                  Center(
                    child: RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 46,
                      itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.primary),
                      onRatingUpdate: (r) => setState(() => _rating = r),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text(_ratingLabel(), style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 20),

                  // Barra de distribución (decorativa)
                  _RatingBar(stars: 5, pct: 0.85),
                  _RatingBar(stars: 4, pct: 0.10),

                  const SizedBox(height: 20),
                  const Text('Deja un comentario', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe tu experiencia con nuestro servicio técnico...',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allTags.map((tag) {
                      final sel = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () => setState(() => sel ? _selectedTags.remove(tag) : _selectedTags.add(tag)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : Colors.transparent,
                            border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(tag, style: TextStyle(color: sel ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _loading ? null : _enviar,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Enviar Reseña'),
                  ),
                  const SizedBox(height: 12),
                  const Center(child: Text('TU RESEÑA NOS AYUDA A MEJORAR LA CALIDAD DEL SERVICIO', style: TextStyle(fontSize: 11, color: AppColors.textHint, letterSpacing: 0.5), textAlign: TextAlign.center)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final double pct;
  const _RatingBar({required this.stars, required this.pct});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Text('$stars', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: pct, backgroundColor: AppColors.border, color: AppColors.primary, minHeight: 6))),
        const SizedBox(width: 8),
        Text('${(pct * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    ),
  );
}
