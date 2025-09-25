// lib/view/screens/history/widgets/history_card.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class HistoryCard extends StatefulWidget {
  final String hospital;
  final String specialty;
  final String date;
  final String motivoConsulta;
  final String diagnostico;
  final VoidCallback onDetailsPressed;

  const HistoryCard({
    super.key,
    required this.hospital,
    required this.specialty,
    required this.date,
    required this.motivoConsulta,
    required this.onDetailsPressed,
    required this.diagnostico,
  });

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor(context).withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header compacto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.specialty,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor(context),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildDateChip(),
              ],
            ),

            const SizedBox(height: 10),

            // Línea divisoria más delgada
            Container(
              height: 2,
              width: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context).withAlpha(150),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            const SizedBox(height: 10),

            // Contenido compacto
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono más compacto
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor(context).withAlpha(150),
                        AppColors.primaryColor(context).withAlpha(170),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedHospital01,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),

                // Información compacta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hospital
                      Text(
                        widget.hospital,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(context),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Diagnostico:",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textColor(context),
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.diagnostico,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textLightColor(context),
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Botón más compacto
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onDetailsPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Ver Detalles",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryColor(context).withAlpha(220),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  HugeIcons.strokeRoundedArrowRight01,
                  size: 16,
                  color: AppColors.primaryColor(context).withAlpha(200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentColor(context).withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            HugeIcons.strokeRoundedCalendar01,
            size: 12,
            color: AppColors.accentColor(context),
          ),
          const SizedBox(width: 3),
          Text(
            widget.date,
            style: TextStyle(
              color: AppColors.accentColor(context),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
