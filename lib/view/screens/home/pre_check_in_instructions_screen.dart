import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:provider/provider.dart';

class PreCheckInInstructionsScreen extends StatefulWidget {
  final CitaModel appointment;
  const PreCheckInInstructionsScreen({super.key, required this.appointment});

  @override
  State<PreCheckInInstructionsScreen> createState() =>
      _PreCheckInInstructionsScreenState();
}

class _PreCheckInInstructionsScreenState
    extends State<PreCheckInInstructionsScreen> {
  bool _isLoading = false;

  Future<void> _confirmAttendance() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final appointmentViewModel = context.read<AppointmentViewModel>();
    final success = await appointmentViewModel.confirmAttendance(
      widget.appointment.id!,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        _showCustomSnackBar(
          context,
          message: 'asistencia_confirmada_ya_puedes_escanear_el_qr_al_llegar'
              .tr(),
          isSuccess: true,
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        _showCustomSnackBar(
          context,
          message: 'Error al confirmar. Inténtalo de nuevo.',
          isSuccess: false,
        );
      }
    }
  }

  void _showCustomSnackBar(
    BuildContext context, {
    required String message,
    required bool isSuccess,
  }) {
    final color = isSuccess
        ? AppColors.successColor(context)
        : AppColors.warningColor(context);
    final icon = isSuccess ? Icons.check_circle_rounded : Icons.error_rounded;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, Color.lerp(color, Colors.black, 0.1)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(100),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.white.withAlpha(30), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withAlpha(50),
                    width: 1.2,
                  ),
                ),
                child: Icon(icon, color: Colors.white.withAlpha(230), size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.3,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    final accentColor = AppColors.accentColor(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Preparación para Check-In',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(25),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header espectacular
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    Color.lerp(primaryColor, Colors.blue.shade700, 0.3)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha(120),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withAlpha(60),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedQrCode,
                      size: 24,
                      color: Colors.white.withAlpha(220),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Todo listo para tu Check-In!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'sigue_estos_pasos_para_una_experiencia_fluida'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(200),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card de preparación - Mejorada con más información
            _buildPreparationCard(context),

            const SizedBox(height: 16),

            // Card de QR - Diseño completamente renovado
            _buildQRProcessCard(context, accentColor),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  Widget _buildPreparationCard(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header mejorado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withAlpha(15), primaryColor.withAlpha(8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primaryColor.withAlpha(40),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedCheckList,
                    size: 18,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'prepara_tu_visita'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          // Contenido mejorado con más información
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                _EnhancedStepRow(
                  icon: HugeIcons.strokeRoundedPinLocation01,
                  title: 'dirgete_al_hospital'.tr(),
                  description:
                      '${widget.appointment.hospital} - ${widget.appointment.specialty ?? 'Consulta Externa'}',
                ),
                const SizedBox(height: 12),
                _EnhancedStepRow(
                  icon: HugeIcons.strokeRoundedClock02,
                  title: 'llega_con_anticipacin'.tr(),
                  description:
                      'Te recomendamos estar 45 minutos antes de tu cita programada',
                ),
                const SizedBox(height: 12),
                _EnhancedStepRow(
                  icon: HugeIcons.strokeRoundedQrCode,
                  title: 'busca_el_qr_de_llegada'.tr(),
                  description:
                      'Los códigos QR se encuentran en las salas de espera de cada área de especialidad',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRProcessCard(BuildContext context, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header completamente nuevo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor.withAlpha(20), accentColor.withAlpha(10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Icono nuevo y más atractivo
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        Color.lerp(accentColor, Colors.black, 0.2)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedQrCode,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'proceso_de_escaneo_qr'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'sigue_estos_pasos_para_registrar_tu_llegada'.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido completamente renovado
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Información sobre ubicación de QR
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withAlpha(20),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedInformationCircle,
                        size: 16,
                        color: accentColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'encuentra_los_qr_en_las_salas_de_espera_de_cada_especialidad'
                              .tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Pasos mejorados con más información
                _EnhancedQRStep(
                  number: 1,
                  icon: HugeIcons.strokeRoundedPhoneArrowDown,
                  title: 'abre_el_escner_qr'.tr(),
                  description:
                      'Desde la app, toca el botón "Escanear QR" para activar la cámara',
                  accentColor: accentColor,
                ),
                const SizedBox(height: 12),
                _EnhancedQRStep(
                  number: 2,
                  icon: HugeIcons.strokeRoundedQrCode01,
                  title: 'enfoca_el_cdigo'.tr(),
                  description:
                      'Apunta la cámara hacia el QR ubicado en la sala de espera',
                  accentColor: accentColor,
                ),
                const SizedBox(height: 12),
                _EnhancedQRStep(
                  number: 3,
                  icon: HugeIcons.strokeRoundedCheckList,
                  title: 'confirmacin_automtica'.tr(),
                  description:
                      'Tu llegada se registrará instantáneamente en el sistema',
                  accentColor: accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              Color.lerp(primaryColor, Colors.blue.shade700, 0.3)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withAlpha(120),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _confirmAttendance,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withAlpha(200),
                        ),
                      ),
                    )
                  else
                    Icon(
                      HugeIcons.strokeRoundedTickDouble03,
                      size: 18,
                      color: Colors.white.withAlpha(230),
                    ),
                  const SizedBox(width: 10),
                  Text(
                    _isLoading ? 'Confirmando...' : 'confirmar_asistencia'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

// Widgets auxiliares mejorados

class _EnhancedStepRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EnhancedStepRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryColor.withAlpha(25), width: 1.2),
          ),
          child: Icon(icon, size: 16, color: primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnhancedQRStep extends StatelessWidget {
  final int number;
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _EnhancedQRStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          // Número con diseño mejorado
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withAlpha(80),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Icono del paso
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withAlpha(25), width: 1),
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 12),

          // Contenido textual mejorado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
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
