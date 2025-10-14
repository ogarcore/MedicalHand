import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/family/family_members_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'add_family_member_screen.dart';
import 'widgets/empty_family_view.dart';
import 'widgets/family_member_card.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  @override
  Widget build(BuildContext context) {
    final familyViewModel = Provider.of<FamilyViewModel>(
      context,
      listen: false,
    );
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    final currentUser = userViewModel.currentUser;
    final activeProfile = userViewModel.activeProfile;

    final bool isTutorViewing = currentUser?.uid == activeProfile?.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'gestin_de_familiares'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: familyViewModel.getFamilyMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los familiares.'));
          }

          final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;

          if (!hasData) {
            return EmptyFamilyView(isTutorViewing: isTutorViewing);
          }

          final familyMembers = snapshot.data!;
          return Scaffold(
            backgroundColor: AppColors.backgroundColor(context),
            body: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ), // Espacio para el botón
              itemCount: familyMembers.length,
              itemBuilder: (context, index) {
                final member = familyMembers[index];
                return FamilyMemberCard(member: member);
              },
            ),
            // CAMBIO: La visibilidad del botón ahora depende de 'isTutorViewing' Y 'hasData'
            floatingActionButton: (isTutorViewing && hasData)
                ? FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddFamilyMemberScreen(),
                        ),
                      );
                    },
                    label: Text(
                      'aadir_familiar'.tr(),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    icon: const Icon(
                      HugeIcons.strokeRoundedAddCircleHalfDot,
                      size: 20,
                    ),
                    backgroundColor: AppColors.primaryColor(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }
}
