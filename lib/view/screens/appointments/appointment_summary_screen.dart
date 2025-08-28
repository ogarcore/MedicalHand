// lib/view/screens/appointments/appointment_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';

class AppointmentSummaryScreen extends StatelessWidget {
  final String specialty;
  final String hospital;
  final String reason;

  const AppointmentSummaryScreen({
    super.key,
    required this.specialty,
    required this.hospital,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Resumen de tu Cita'),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(100),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textColor),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono y título principal
            Center(
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.15),
                          AppColors.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedTask01,
                      size: 42,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '¡Revisa tu solicitud!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Confirma que los datos de tu cita son correctos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textLightColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Tarjeta de resumen
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    icon: HugeIcons.strokeRoundedMicroscope,
                    label: 'Especialidad',
                    value: specialty,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.grey.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryRow(
                    icon: HugeIcons.strokeRoundedHospital01,
                    label: 'Centro Médico',
                    value: hospital,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.grey.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryRow(
                    icon: HugeIcons.strokeRoundedNote,
                    label: 'Motivo de Consulta',
                    value: reason,
                    isMultiline: true,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Botón de confirmación
            PrimaryButton(
              text: 'Confirmar Solicitud',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('¡Solicitud enviada con éxito!'),
                    backgroundColor: AppColors.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textLightColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: isMultiline ? 1.4 : 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}