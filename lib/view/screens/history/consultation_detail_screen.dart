// lib/view/screens/history/consultation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class ConsultationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> consultationData;

  const ConsultationDetailScreen({super.key, required this.consultationData});

  @override
  Widget build(BuildContext context) {
    final String hospital = consultationData['hospital'] ?? 'No disponible';
    final String specialty = consultationData['specialty'] ?? 'No disponible';
    final String date = consultationData['date'] ?? 'No disponible';
    final String doctor = consultationData['doctor'] ?? 'No disponible';
    final String diagnostico =
        consultationData['diagnostico'] ?? 'No disponible';
    final String tratamiento =
        consultationData['tratamiento'] ?? 'No disponible';
    final List prescriptions = consultationData['prescriptions'] ?? [];
    final List exams = consultationData['examsRequested'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          specialty,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor(context),
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
            _buildHeaderCard(context, hospital, date, doctor),
            const SizedBox(height: 20),

            // Sección de Diagnóstico
            _buildCompactSectionCard(
              context,
              icon: HugeIcons.strokeRoundedHealth,
              title: 'Diagnóstico',
              content: diagnostico,
              iconColor: AppColors.primaryColor(context),
            ),
            const SizedBox(height: 12),

            // Sección de Tratamiento
            _buildCompactSectionCard(
              context,
              icon: HugeIcons.strokeRoundedGivePill,
              title: 'Tratamiento Indicado',
              content: tratamiento,
              iconColor: AppColors.secondaryColor(context),
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
                iconColor: Colors.purple,
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
                iconColor: AppColors.graceColor(context),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    String hospital,
    String date,
    String doctor,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor(context);
    final accentColor = AppColors.accentColor(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? primaryColor.withAlpha(70) : primaryColor.withAlpha(20),
            isDark ? accentColor.withAlpha(50) : accentColor.withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withAlpha(170),
                            accentColor.withAlpha(170),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withAlpha(70),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedHospital01,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        hospital,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: AppColors.textColor(context),
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildInfoRowWithBackground(
                  context,
                  icon: HugeIcons.strokeRoundedCalendar01,
                  text: date,
                  iconColor: primaryColor,
                ),
                const SizedBox(height: 12),
                _buildInfoRowWithBackground(
                  context,
                  icon: HugeIcons.strokeRoundedDoctor01,
                  text: doctor,
                  iconColor: accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithBackground(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(100)
            : Colors.white.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Contenido
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: AppColors.textColor(context),
              ),
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
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Lista de items
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 16, right: 10),
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor(context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        itemBuilder(item),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: AppColors.textColor(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
