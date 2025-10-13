import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final List<Widget>? actions;
  final bool showCloseButton;
  final double? maxWidth;
  final IconData? icon;
  final bool isLoading; // ← agregado

  const CustomModal({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.actions,
    this.showCloseButton = true,
    this.maxWidth,
    this.icon,
    this.isLoading = false, // ← valor opcional por defecto
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 500),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header con gradiente mejorado
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor(context).withAlpha(230),
                            AppColors.accentColor(context).withAlpha(220),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          if (icon != null)
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(30),
                              ),
                              child: Icon(icon, color: Colors.white, size: 24),
                            ),
                          if (icon != null) const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    subtitle!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white.withAlpha(220),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contenido
                    Padding(padding: const EdgeInsets.all(20), child: content),

                    // Acciones (si existen)
                    if (actions != null && actions!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 12,
                          runSpacing: 12,
                          children: actions!.map((action) => action).toList(),
                        ),
                      ),
                  ],
                ),

                // 🌀 Capa de carga (opcional)
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.7),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Botón personalizado para modales - Versión mejorada
class ModalButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isWarning;
  final bool isLoading; // ← agregado

  const ModalButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.isWarning = false,
    this.isLoading = false, // ← valor opcional por defecto
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isWarning) {
      backgroundColor = AppColors.warningColor(context);
      textColor = Colors.white;
      borderColor = AppColors.warningColor(context);
    } else if (isPrimary) {
      backgroundColor = AppColors.accentColor(context);
      textColor = Colors.white;
      borderColor = AppColors.accentColor(context);
    } else {
      backgroundColor = Colors.transparent;
      textColor = AppColors.textColor(context);
      borderColor = AppColors.textLightColor(context).withAlpha(80);
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: 1.2),
        ),
        elevation: 2,
        shadowColor: Colors.transparent,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: textColor,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(text),
    );
  }
}
