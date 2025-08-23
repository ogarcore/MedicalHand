import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../login/login_screen.dart';
import '../registration/registration_step1_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado moderno
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withAlpha(50),
                  AppColors.backgroundColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Círculos decorativos con sombras suaves
          Positioned(
            top: -size.height * 0.18,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withAlpha(15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withAlpha(60),
                    blurRadius: 40,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.2,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              decoration: BoxDecoration(
                color: AppColors.accentColor.withAlpha(25),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentColor.withAlpha(100),
                    blurRadius: 50,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal centrado
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo / Ilustración
                      Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primaryColor.withAlpha(50),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor.withAlpha(180),
                                    AppColors.accentColor.withAlpha(180),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withAlpha(80),
                                    blurRadius: 25,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.medical_services_outlined,
                                size: 65,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Texto
                      Text(
                        'MedicalHand',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tu salud, en tus manos.\nRápido y fácil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 140),
                      // Botones
                      SecondaryButton(
                        text: 'Registrarse',
                        onPressed: () {
                          // ESTA ES LA LÍNEA QUE CAMBIA
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegistrationStep1Screen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),

                      PrimaryButton(
                        text: 'Iniciar Sesión',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
