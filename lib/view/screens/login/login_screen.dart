import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_screen.dart';
import '../../../app/core/constants/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor.withAlpha(30), AppColors.backgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Círculos decorativos con sombras suaves
          Positioned(
            top: -size.height * 0.25,
            left: -size.width * 0.2,
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
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withAlpha(10),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withAlpha(80),
                    blurRadius: 50,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo/Icono moderno
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withAlpha(50),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.supervised_user_circle,
                        size: 60,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Títulos
                  Text(
                    '¡Bienvenido/a!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accede a tu cuenta para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Campos de texto modernos
                  CustomTextField(
                    controller: emailController,
                    labelText: 'Correo electrónico',
                    hintText: 'Ingrese su correo',
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 25),

                  CustomTextField(
                    controller: passwordController,
                    labelText: 'Contraseña',
                    hintText: 'Ingresa su contraseña',
                    isPassword: true,
                    icon: Icons.lock_outline,
                  ),

                  const SizedBox(height: 6),

                  // Olvidé contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Botón principal
                  SizedBox(
                    child: PrimaryButton(
                      text: 'Iniciar Sesión',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divisor
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'O ingresa con',
                          style: TextStyle(
                            color: Colors.grey[600], 
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 280,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Image.asset(
                            'assets/images/google_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        label: const Text(
                          'Iniciar sesión con Google',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.5, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide.none,
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: AppColors.textColor,
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta?',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                        ),
                        child: Text(
                          'Regístrate',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
