// lib/view/screens/history/consultation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class ConsultationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> consultationData;

  const ConsultationDetailScreen({super.key, required this.consultationData});

  @override
  Widget build(BuildContext context) {
    
    // Lectura de datos desde el mapa con valores por defecto
    final String hospital = consultationData['hospital'] ?? 'No disponible';
    final String specialty = consultationData['specialty'] ?? 'No disponible';
    final String date = consultationData['date'] ?? 'No disponible';
    final String doctor = consultationData['doctor'] ?? 'No disponible';
    final String motivoConsulta = consultationData['motivoConsulta'] ?? 'No disponible';
    final String diagnostico = consultationData['diagnostico'] ?? 'No disponible';
    final String tratamiento = consultationData['tratamiento'] ?? 'No disponible';
    final List prescriptions = consultationData['prescriptions'] ?? [];
    final List exams = consultationData['examsRequested'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          "Detalles de Consulta",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor(context),
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textColor(context), size: 22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header compacto
            _buildCompactHeader(context, hospital, date, doctor, specialty),
            const SizedBox(height: 20),
            
            // Contenido principal compacto
            Column(
              children: [
                // Sección de Motivo de Consulta
                _buildCompactSection(
                  context,
                  icon: HugeIcons.strokeRoundedQuestion,
                  title: 'Motivo de la Consulta',
                  content: motivoConsulta,
                  accentColor: Colors.blue,
                ),
                const SizedBox(height: 12),

                // Sección de Diagnóstico
                _buildCompactSection(
                  context,
                  icon: HugeIcons.strokeRoundedHealth,
                  title: 'Diagnóstico',
                  content: diagnostico,
                  accentColor: AppColors.primaryColor(context),
                ),
                const SizedBox(height: 12),

                // Sección de Tratamiento
                _buildCompactSection(
                  context,
                  icon: HugeIcons.strokeRoundedGivePill,
                  title: 'Tratamiento Indicado',
                  content: tratamiento,
                  accentColor: AppColors.secondaryColor(context),
                ),

                // Sección de Recetas Médicas
                if (prescriptions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildCompactListSection(
                    context,
                    icon: HugeIcons.strokeRoundedPinLocation01,
                    title: 'Recetas Médicas',
                    items: prescriptions,
                    itemBuilder: (item) =>
                        '${item['nombre']} (${item['dosis']}) - ${item['frecuencia']}, por ${item['duracion']}.',
                    accentColor: Colors.purple,
                  ),
                ],

                // Sección de Exámenes Solicitados
                if (exams.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildCompactListSection(
                    context,
                    icon: HugeIcons.strokeRoundedMicroscope,
                    title: 'Exámenes Solicitados',
                    items: exams,
                    itemBuilder: (item) => '${item['nombre']}',
                    accentColor: AppColors.graceColor(context),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader(
    BuildContext context,
    String hospital,
    String date,
    String doctor,
    String specialty,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withAlpha(8) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 15 : 5),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Especialidad compacta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(isDark ? 25 : 12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryColor.withAlpha(isDark ? 40 : 20),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  HugeIcons.strokeRoundedArcBrowser,
                  size: 12,
                  color: primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Información principal compacta
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withAlpha(30),
                      primaryColor.withAlpha(15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: primaryColor.withAlpha(25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  HugeIcons.strokeRoundedHospital01,
                  size: 18,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Centro Médico',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textColor(context).withAlpha(130),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Grid de información compacto
          Row(
            children: [
              Expanded(
                child: _buildCompactDetailCard(
                  context,
                  icon: HugeIcons.strokeRoundedCalendar01,
                  title: 'Fecha',
                  value: date,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactDetailCard(
                  context,
                  icon: HugeIcons.strokeRoundedDoctor01,
                  title: 'Médico',
                  value: doctor,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDark ? Colors.white.withAlpha(6) : color.withAlpha(6),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(12) : color.withAlpha(15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor(context),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color accentColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? Colors.white.withAlpha(8) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 12 : 4),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header compacto
          Container(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withAlpha(40),
                        accentColor.withAlpha(20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withAlpha(30),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido compacto
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                // Línea divisoria sutil
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark ? Colors.white.withAlpha(30) : Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textColor(context).withAlpha(220),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactListSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List items,
    required String Function(Map) itemBuilder,
    required Color accentColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? Colors.white.withAlpha(8) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 12 : 4),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header compacto
          Container(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withAlpha(40),
                        accentColor.withAlpha(20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withAlpha(30),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista compacta
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                // Línea divisoria
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark ? Colors.white.withAlpha(30) : Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                ...items.asMap().entries.map((entry) {
                  final item = entry.value;
                  final isLast = entry.key == items.length - 1;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Indicador compacto
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? Colors.white.withAlpha(6) : Colors.grey.shade50,
                              border: Border.all(
                                color: isDark ? Colors.white.withAlpha(12) : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              itemBuilder(item),
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: AppColors.textColor(context).withAlpha(220),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}