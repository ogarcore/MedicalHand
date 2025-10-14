import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/history/widgets/history_card.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class HistoryCard extends StatefulWidget {
  final String hospital;
  final String specialty;
  final String date;
  final String diagnostico;
  final VoidCallback onDetailsPressed;

  const HistoryCard({
    super.key,
    required this.hospital,
    required this.specialty,
    required this.date,
    required this.onDetailsPressed,
    required this.diagnostico,
  });

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  @override
  Widget build(BuildContext context) {
    // Se definen los colores para el gradiente del header, similar al estado 'finalizada'
    final secondaryColor = AppColors.secondaryColor(context);
    final headerGradientColors = [
      secondaryColor.withAlpha(200),
      Color.lerp(
        AppColors.primaryColor(context).withAlpha(200),
        Colors.black,
        0.15,
      )!,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ---- Header con gradiente (del primer código) ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: headerGradientColors,
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
                Expanded(
                  child: Text(
                    widget.specialty, // Usamos la especialidad
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(240),
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildDateChip(widget.date), // Chip para la fecha
              ],
            ),
          ),

          // ---- Cuerpo de la tarjeta (del primer código) ----
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(title: widget.hospital),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: HugeIcons.strokeRoundedBloodBottle,
                  text: widget.diagnostico, // Mostramos el diagnóstico
                  subtitle: 'diagnstico'.tr(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onDetailsPressed,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor(context),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero, // evita que ocupe todo el ancho
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // ocupa solo lo necesario
                        children: [
                          Text(
                            'ver_detalles'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            HugeIcons.strokeRoundedArrowRight01,
                            size: 18,
                            color: AppColors.primaryColor(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Helper para mostrar información con ícono (del primer código) ----
  Widget _buildInfoRow({
    IconData? icon,
    String? title,
    String? subtitle,
    String? text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16.5, color: AppColors.primaryColor(context)),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              if (subtitle != null) ...[
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textColor(context).withAlpha(220),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              if (text != null) ...[
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLightColor(context),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---- Helper para el chip de fecha (estilo del primer código) ----
  Widget _buildDateChip(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(80), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            HugeIcons.strokeRoundedCalendar01,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            date,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
