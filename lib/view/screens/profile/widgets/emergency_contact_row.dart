import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class EmergencyContactRow extends StatelessWidget {
  final bool hasContact;
  final Map<String, dynamic> contact;
  final VoidCallback onEdit;

  const EmergencyContactRow({
    super.key,
    required this.hasContact,
    required this.contact,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade500, Colors.red.shade400],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade300.withAlpha(60),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              HugeIcons.strokeRoundedCall,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'contacto_de_emergencia'.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                if (hasContact) ...[
                  Text(
                    contact['name'] ?? 'nombre_no_disponible'.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    contact['phone'] ?? 'telfono_no_disponible'.tr(),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ] else ...[
                  Text(
                    'no_configurado'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    'toca_para_agregar'.tr(),
                    style: TextStyle(
                      fontSize: 11,
                      color: primaryColor.withAlpha(150),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withAlpha(40), width: 1.2),
            ),
            child: IconButton(
              onPressed: onEdit,
              icon: Icon(
                hasContact ? HugeIcons.strokeRoundedEdit01 : HugeIcons.strokeRoundedPlusMinus,
                size: 14,
                color: primaryColor,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}