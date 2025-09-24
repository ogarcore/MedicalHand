import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view/widgets/secondary_button.dart';

class AppointmentNavigationBar extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNextPressed;
  final VoidCallback onPreviousPressed;
  final Color? primaryColor;
  final Color? primaryForegroundColor;
  final Color? primaryIconColor;
  final Color? primaryShadowColor;

  // 👇 Parámetros personalizables para SecondaryButton
  final Color? secondaryColor;
  final BorderSide? secondarySide;
  final Color? secondaryForegroundColor;
  final Color? secondaryIconColor;
  final Color? secondaryShadowColor;

  const AppointmentNavigationBar({
    super.key,
    required this.currentStep,
    required this.onNextPressed,
    required this.onPreviousPressed,
    this.primaryColor,
    this.primaryForegroundColor,
    this.primaryIconColor,
    this.primaryShadowColor,
    this.secondaryColor,
    this.secondarySide,
    this.secondaryForegroundColor,
    this.secondaryIconColor,
    this.secondaryShadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                flex: 1,
                child: SecondaryButton(
                  text: "Atrás",
                  onPressed: onPreviousPressed,
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side:
                      secondarySide ??
                      BorderSide(
                        color: AppColors.primaryColor(context),
                        width: 1,
                      ),
                  foregroundColor:
                      secondaryForegroundColor ??
                      AppColors.primaryColor(context),
                  shadowColor: secondaryShadowColor,
                  icon: Icon(
                    HugeIcons.strokeRoundedArrowLeft01,
                    size: 18,
                    color:
                        secondaryIconColor ??
                        secondaryColor ??
                        AppColors.primaryColor(context),
                  ),
                ),
              ),

            if (currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: currentStep == 0 ? 1 : 2,
              child: PrimaryButton(
                text: currentStep < 2 ? "Continuar" : "Revisar datos",
                onPressed: onNextPressed,
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                backgroundColor:
                    primaryColor ??
                    AppColors.primaryColor(context).withAlpha(230),
                icon: currentStep < 2
                    ? Icon(
                        HugeIcons.strokeRoundedArrowRight01,
                        size: 20,
                        color: primaryIconColor ?? Colors.white,
                      )
                    : null,
                iconAtEnd: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
