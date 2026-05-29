import 'package:flutter/material.dart';
import 'dart:io';
import '../../config/app_colors.dart';
import 'request_summary_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final int categoriaId;
  final String categoriaName;
  final String descripcion;
  final String urgencia;
  final String direccion;
  final double? latitud;
  final double? longitud;
  final File? imagen;
  const ScheduleScreen({super.key, required this.categoriaId, required this.categoriaName, required this.descripcion, required this.urgencia, required this.direccion, this.latitud, this.longitud, this.imagen});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedHorario;
  int _currentMonth = 0;

  final List<Map<String, String>> _horarios = [
    {'id': 'manana', 'label': 'MAÑANA', 'time': '09:00 - 12:00', 'desc': 'Ideal para revisiones de hardware complejas.', 'inicio': '09:00', 'fin': '12:00'},
    {'id': 'tarde', 'label': 'TARDE', 'time': '14:00 - 17:00', 'desc': 'Recomendado para soporte de software y red.', 'inicio': '14:00', 'fin': '17:00'},
    {'id': 'noche', 'label': 'NOCHE', 'time': '18:00 - 21:00', 'desc': 'Cupos Limitados', 'inicio': '18:00', 'fin': '21:00'},
  ];

  List<DateTime> _getDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(last.day, (i) => DateTime(month.year, month.month, i + 1));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month + _currentMonth);
    final days = _getDaysInMonth(month);
    final weekDays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final months = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('J&P Tech Support'),
        actions: [CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, color: AppColors.primary))],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(children: [
              const Text('Agendar Visita Técnica', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text('PASO 2 DE 3', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700))),
            ]),
          ),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: 0.66, backgroundColor: AppColors.border, color: AppColors.primary, minHeight: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Agendar Visita Técnica', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const Text('Seleccione el momento que mejor se adapte a su disponibilidad.', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),

                  // Calendario
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${months[month.month - 1]} ${month.year}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            Row(children: [
                              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _currentMonth--)),
                              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _currentMonth++)),
                            ]),
                          ],
                        ),
                        // Headers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: weekDays.map((d) => SizedBox(width: 36, child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)))).toList(),
                        ),
                        const SizedBox(height: 8),
                        // Days grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
                          itemCount: days.first.weekday % 7 + days.length,
                          itemBuilder: (_, i) {
                            final emptyBefore = days.first.weekday % 7;
                            if (i < emptyBefore) return const SizedBox();
                            final day = days[i - emptyBefore];
                            final isSelected = day.day == _selectedDate.day && day.month == _selectedDate.month;
                            final isPast = day.isBefore(DateTime(now.year, now.month, now.day));
                            return GestureDetector(
                              onTap: isPast ? null : () => setState(() => _selectedDate = day),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text('${day.day}', style: TextStyle(
                                    color: isPast ? AppColors.textHint : (isSelected ? Colors.white : AppColors.textPrimary),
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                  )),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Usted ha seleccionado el ${['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'][_selectedDate.weekday % 7]} ${_selectedDate.day}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Horarios Disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ..._horarios.map((h) => GestureDetector(
                    onTap: () => setState(() => _selectedHorario = h['id']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _selectedHorario == h['id'] ? AppColors.primary : AppColors.border, width: _selectedHorario == h['id'] ? 2 : 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h['label']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1)),
                          Text(h['time']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          Text(h['desc']!, style: TextStyle(fontSize: 12, color: h['id'] == 'noche' ? AppColors.error : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('ATRÁS'))),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selectedHorario == null ? null : () {
                      final h = _horarios.firstWhere((h) => h['id'] == _selectedHorario);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RequestSummaryScreen(
                        categoriaId: widget.categoriaId,
                        categoriaName: widget.categoriaName,
                        descripcion: widget.descripcion,
                        urgencia: widget.urgencia,
                        direccion: widget.direccion,
                        latitud: widget.latitud,
                        longitud: widget.longitud,
                        fecha: _selectedDate,
                        horarioInicio: h['inicio']!,
                        horarioFin: h['fin']!,
                        imagen: widget.imagen,
                      )));
                    },
                    child: const Text('CONTINUAR'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
