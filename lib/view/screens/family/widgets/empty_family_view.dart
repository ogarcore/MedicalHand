import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/screens/family/add_family_member_screen.dart';

class EmptyFamilyView extends StatelessWidget {
  final bool isTutorViewing;

  const EmptyFamilyView({super.key, required this.isTutorViewing});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                HugeIcons.strokeRoundedUserGroup02,
                size: 56,
                color: AppColors.primaryColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'administra_los_perfiles_de_tu_familia'.tr(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor(context),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'aade_a_tus_familiares_para_gestionar_sus_perfiles_mdicos_his'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLightColor(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _buildFeatureRow(
              context: context,
              icon: HugeIcons.strokeRoundedClinic,
              text: 'historial_mdico_compartido'.tr(),
            ),
            const SizedBox(height: 10),
            _buildFeatureRow(
              context: context,
              icon: HugeIcons.strokeRoundedCalendarLock02,
              text: 'gestin_de_citas_familiar'.tr(),
            ),
            const SizedBox(height: 10),
            _buildFeatureRow(
              context: context,
              icon: HugeIcons.strokeRoundedSquareLockPassword,
              text: 'acceso_seguro_y_controlado'.tr(),
            ),
            const SizedBox(height: 32),
            if (isTutorViewing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddFamilyMemberScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    HugeIcons.strokeRoundedAddCircleHalfDot,
                    size: 18,
                  ),
                  label: Text(
                    'Comenzar - Añadir Primer Familiar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor(context).withAlpha(15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor(context)),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
