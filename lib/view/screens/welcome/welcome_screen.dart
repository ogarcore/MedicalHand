import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../login/login_screen.dart';
import '../registration/registration_step1_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<bool> _hasInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  void _showNoConnectionMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.warningColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'sin_conexin_a_internet'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _handleLogin(BuildContext context) async {
    final connected = await _hasInternet();
    if (!context.mounted) return;
    if (!connected) {
      _showNoConnectionMessage(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _handleRegister(BuildContext context) async {
    final connected = await _hasInternet();
    if (!context.mounted) return;
    if (!connected) {
      _showNoConnectionMessage(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationStep1Screen()),
    );
  }

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
                  AppColors.primaryColor(context).withAlpha(60),
                  AppColors.backgroundColor(context),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Círculos decorativos
          Positioned(
            top: -size.height * 0.24,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor(context).withAlpha(8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryColor(context).withAlpha(60),
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
                color: AppColors.secondaryColor(context).withAlpha(5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryColor(context).withAlpha(100),
                    blurRadius: 50,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor(context).withAlpha(5),
                              AppColors.primaryColor(context).withAlpha(5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor(
                                context,
                              ).withAlpha(5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/icono.png',
                          width: 150,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Título
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'medical'.tr(),
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textColor(context),
                                letterSpacing: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: 'hand'.tr(),
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryColor(context),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'el_poder_de_gestionar_tu_bienestar_nen_la_palma_de_tu_mano'
                            .tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 120),

                      // Botones
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                        ), // 🔹 Ajusta el valor a tu gusto
                        child: Column(
                          children: [
                            SecondaryButton(
                              text: 'registrarse'.tr(),
                              width: double
                                  .infinity, // 🔹 para que ocupe todo el ancho disponible dentro del padding
                              onPressed: () => _handleRegister(context),
                            ),
                            const SizedBox(height: 18),
                            PrimaryButton(
                              text: 'iniciar_sesin'.tr(),
                              width:
                                  double.infinity, // 🔹 igual que el anterior
                              onPressed: () => _handleLogin(context),
                            ),
                          ],
                        ),
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
