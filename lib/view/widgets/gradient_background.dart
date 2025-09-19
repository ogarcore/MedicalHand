import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Contenedor con el gradiente principal
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withAlpha(30),
                AppColors.backgroundColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Círculo decorativo superior derecho
        Positioned(
          top: -size.height * 0.25,
          right: -size.width * 0.2,
          child: Container(
            width: size.width * 0.8,
            height: size.width * 0.8,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withAlpha(15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withAlpha(50),
                  blurRadius: 40,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
        // Círculo decorativo inferior izquierdo
        Positioned(
          bottom: -size.height * 0.2,
          left: -size.width * 0.2,
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
        // El contenido que se mostrará encima del fondo
        child,
      ],
    );
  }
}
