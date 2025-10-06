import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class NoAppointmentCard extends StatelessWidget {
  const NoAppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withAlpha(30),
            AppColors.secondaryColor(context).withAlpha(20),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: primaryColor.withAlpha(20),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono con contenedor mejorado
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withAlpha(25),
                  AppColors.secondaryColor(context).withAlpha(15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withAlpha(40),
                width: 1.5,
              ),
            ),
            child: Icon(
              HugeIcons.strokeRoundedCalendarMinus02,
              size: 26,
              color: primaryColor.withAlpha(220),
            ),
          ),
          const SizedBox(height: 16),
          
          // Texto principal
          Text(
            'No tienes citas programadas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor(context),
              letterSpacing: -0.2,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          
          // Texto secundario compacto
          Text(
            'Es un buen momento para programar tu próximo chequeo médico',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          
          // Botón mejorado
          
        ],
      ),
    );
  }
}