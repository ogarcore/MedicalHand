// lib/view/screens/appointments/appointment_options.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/screens/appointments/external_appoinment_screen.dart';
import 'package:p_hn25/view/screens/appointments/request_appointment_screen.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view/widgets/secondary_button.dart';

class AppointmentOptionsScreen extends StatelessWidget {
  const AppointmentOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // AppBar con gradiente elegante
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor.withAlpha(243),
                  AppColors.primaryColor.withAlpha(217),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withAlpha(76),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: AppBar(
              title: const Text(
                'Tipo de Cita',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
              iconTheme: const IconThemeData(color: Colors.white),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
          ),

          // Contenido principal
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: isSmallScreen ? 12 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono y título principal
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            HugeIcons.strokeRoundedCalendar01,
                            color: AppColors.primaryColor,
                            size: isSmallScreen ? 24 : 28,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        const Text(
                          '¿Qué tipo de cita necesitas?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 6),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Selecciona la opción según tu necesidad médica',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textLightColor,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Opciones de cita
                  // Botón 1: Consulta General (SecondaryButton)
                  _buildOptionCard(
                    icon: HugeIcons.strokeRoundedDoctor03,
                    iconColor: AppColors.primaryColor,
                    title: 'Consulta General',
                    description:
                        'Solicita una cita para consulta externa o atención general',
                    buttonText: 'Seleccionar',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RequestAppointmentScreen(),
                      ),
                    ),
                    isHighlighted: false,
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Separador elegante
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withAlpha(38),
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'O',
                          style: TextStyle(
                            color: AppColors.textLightColor.withAlpha(178),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withAlpha(38),
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Botón 2: Carril Rápido (PrimaryButton)
                  _buildOptionCard(
                    icon: HugeIcons.strokeRoundedHospital02,
                    iconColor: AppColors.accentColor,
                    title: 'Referencia Externa',
                    description: 'Para usuarios con referencia médica',
                    details: const [
                      'Referencia en papel de centros de salud',
                      'Hoja de Referencia Digital en app',
                    ],
                    buttonText: 'Seleccionar',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExternalAppoinmentScreen(),
                        ),
                      );
                    },
                    isHighlighted: true,
                    isSmallScreen: isSmallScreen,
                  ),

                  // Espacio flexible para empujar el contenido hacia arriba
                  const Spacer(),

                  // Texto informativo en la parte inferior
                  Padding(
                    padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                    child: Center(
                      child: Text(
                        'Selecciona una opción para continuar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLightColor.withAlpha(204),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    List<String>? details,
    required String buttonText,
    required VoidCallback onPressed,
    required bool isHighlighted,
    required bool isSmallScreen,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isHighlighted ? 20 : 12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isHighlighted
              ? AppColors.accentColor.withAlpha(51)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isSmallScreen ? 40 : 44,
                height: isSmallScreen ? 40 : 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [iconColor.withAlpha(38), iconColor.withAlpha(64)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Text(
            description,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              color: AppColors.textLightColor,
              height: 1.3,
            ),
          ),
          if (details != null) ...[
            SizedBox(height: isSmallScreen ? 8 : 10),
            ...details.map(
              (detail) => Padding(
                padding: EdgeInsets.only(bottom: isSmallScreen ? 4 : 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 5, right: 6),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: AppColors.accentColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: AppColors.textLightColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: isSmallScreen ? 12 : 14),
          // Botones con altura fija para consistencia
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 45 : 50,
            child: isHighlighted
                ? SecondaryButton(
                    text: buttonText,
                    onPressed: onPressed,
                    foregroundColor: AppColors.accentColor,
                    shadowColor: AppColors.accentColor.withAlpha(30),
                    side: const BorderSide(
                      color: AppColors.accentColor,
                      width: 1,
                    ),
                  )
                : PrimaryButton(text: buttonText, onPressed: onPressed),
          ),
        ],
      ),
    );
  }
}
