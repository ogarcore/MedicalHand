import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
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
    return ChangeNotifierProvider(
      create: (_) => FamilyViewModel(),
      child: Consumer<FamilyViewModel>(
        builder: (context, viewModel, child) {
          return StreamBuilder<List<UserModel>>(
            stream: viewModel.getFamilyMembers(),
            builder: (context, snapshot) {
              // preparamos body y estado
              Widget body;
              bool hasFamilyMembers = false;

              if (snapshot.connectionState == ConnectionState.waiting) {
                body = const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                body = const Center(
                  child: Text('Error al cargar los familiares.'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                body = const EmptyFamilyView();
              } else {
                final familyMembers = snapshot.data!;
                hasFamilyMembers = true;
                body = ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: familyMembers.length,
                  itemBuilder: (context, index) {
                    final member = familyMembers[index];
                    return FamilyMemberCard(member: member);
                  },
                );
              }

              return Scaffold(
                backgroundColor: AppColors.backgroundColor,
                appBar: AppBar(
                  title: const Text(
                    'Gestión de Familiares',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  backgroundColor: AppColors.backgroundColor,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  centerTitle: false,
                ),
                body: body,
                floatingActionButton: hasFamilyMembers
                    ? FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddFamilyMemberScreen(),
                            ),
                          );
                        },
                        label: const Text(
                          'Añadir Familiar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        icon: const Icon(
                          HugeIcons.strokeRoundedAddCircleHalfDot,
                          size: 20,
                        ),
                        backgroundColor: AppColors.primaryColor,
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
          );
        },
      ),
    );
  }
}
