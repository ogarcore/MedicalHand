import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/login/widgets/social_login_section.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class SocialLoginSection extends StatelessWidget {
  final bool isGoogleLoading;
  final VoidCallback onGooglePressed;

  const SocialLoginSection({
    super.key,
    required this.isGoogleLoading,
    required this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'o_ingresa_con'.tr(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 280,
            child: isGoogleLoading
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14.5,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor(context),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'cargando'.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: onGooglePressed,
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
                    label: Text(
                      'iniciar_sesin_con_google'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14.5,
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: AppColors.textColor(context),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
