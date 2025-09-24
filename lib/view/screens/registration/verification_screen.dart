import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';
import '../login/login_screen.dart';

class VerificationScreen extends StatelessWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.07,
            vertical: size.height * 0.02,
          ),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ilustración minimalista y elegante
                      Container(
                        width: size.width * 0.35,
                        height: size.width * 0.35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor(context).withAlpha(25),
                              AppColors.primaryColor(context).withAlpha(10),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mark_email_read_outlined,
                          size: size.width * 0.18,
                          color: AppColors.primaryColor(context),
                        ),
                      ),

                      SizedBox(height: size.height * 0.06),

                      // Título principal
                      Text(
                        'Revisa tu correo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor(context),
                          letterSpacing: -0.8,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Descripción elegante
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ),
                        child: Text(
                          'Hemos enviado un enlace de verificación a tu dirección de correo electrónico',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textColor(context).withAlpha(180),
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // Email destacado en tarjeta sutil
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor(context).withAlpha(5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryColor(
                              context,
                            ).withAlpha(25),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor(context),
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'El enlace expirará en 24 horas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor(
                                  context,
                                ).withAlpha(128),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),

                      // Indicadores visuales minimalistas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepIndicator(
                            context: context,
                            icon: Icons.inbox_outlined,
                            text: 'Bandeja de entrada',
                          ),
                          SizedBox(width: 24),
                          _buildStepIndicator(
                            context: context,
                            icon: Icons.folder_outlined,
                            text: 'Carpeta spam',
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.08),
                    ],
                  ),
                ),
              ),

              // Botón principal elegante
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor(context).withAlpha(76),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Volver al Inicio de Sesión',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryColor(context).withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor(context), size: 22),
        ),
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textColor(context).withAlpha(153),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
