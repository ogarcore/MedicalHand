import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/family/add_family_member_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/view/widgets/custom_dropdown.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:provider/provider.dart';
import 'family_verification_screen.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _calculateAge(String dateText) {
    if (AppValidators.validateBirthDate(dateText) != null) return null;
    try {
      final dateParts = dateText.split('/');
      final birthDate = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );
      return DateTime.now().difference(birthDate).inDays ~/ 365;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyViewModel = context.watch<FamilyViewModel>();
    final age = _calculateAge(familyViewModel.birthDateController.text);
    final bool isPhoneOptional = age != null && age < 14;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          title: Text(
            'aadir_nuevo_familiar'.tr(),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionContainer(
                  title: 'informacin_esencial'.tr(),
                  icon: HugeIcons.strokeRoundedUserWarning01,
                  children: [
                    AppStyledDropdown(
                      value: familyViewModel.selectedKinship,
                      items: const [
                        'Madre',
                        'Padre',
                        'Hijo/a',
                        'Cónyuge',
                        'Abuelo/a',
                        'Otro',
                      ],
                      onChanged: (newValue) =>
                          familyViewModel.updateSelectedKinship(newValue),
                      hintText: 'parentesco'.tr(),
                      prefixIcon: HugeIcons.strokeRoundedUserGroup,
                      validator: (value) =>
                          value == null ? 'Selecciona un parentesco' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: familyViewModel.firstNameController,
                      labelText: 'nombres'.tr(),
                      hintText: 'nombres_del_familiar'.tr(),
                      icon: HugeIcons.strokeRoundedUser,
                      validator: (value) => AppValidators.validateGenericEmpty(
                        value,
                        'El nombre',
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: familyViewModel.lastNameController,
                      labelText: 'apellidos'.tr(),
                      hintText: 'apellidos_del_familiar'.tr(),
                      icon: HugeIcons.strokeRoundedUser,
                      validator: (value) => AppValidators.validateGenericEmpty(
                        value,
                        'El apellido',
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: familyViewModel.birthDateController,
                      labelText: 'fecha_de_nacimiento'.tr(),
                      hintText: 'DD/MM/AAAA',
                      icon: HugeIcons.strokeRoundedCalendar01,
                      keyboardType: TextInputType.number,
                      inputFormatters: [DateInputFormatter()],
                      validator: AppValidators.validateBirthDate,
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSectionContainer(
                  title: 'informacin_de_contacto'.tr(),
                  icon: HugeIcons.strokeRoundedContactBook,
                  children: [
                    CustomTextField(
                      controller: familyViewModel.phoneController,
                      labelText: isPhoneOptional
                          ? 'Teléfono (Opcional)'
                          : 'Teléfono',
                      hintText: '0000-0000',
                      icon: HugeIcons.strokeRoundedTelephone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneInputFormatter()],
                      validator: isPhoneOptional
                          ? AppValidators.validateOptionalPhone
                          : AppValidators.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: familyViewModel.addressController,
                      labelText: 'direccin'.tr(),
                      hintText: 'direccin_de_domicilio'.tr(),
                      icon: HugeIcons.strokeRoundedLocation01,
                      validator: (value) => AppValidators.validateGenericEmpty(
                        value,
                        'La dirección',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSectionContainer(
                  title: 'Información Médica (Opcional)',
                  icon: HugeIcons.strokeRoundedHealth,
                  children: [
                    CustomTextField(
                      controller: familyViewModel.bloodTypeController,
                      labelText: 'tipo_de_sangre'.tr(),
                      hintText: 'Ej: O+',
                      icon: HugeIcons.strokeRoundedBloodBag,
                      validator: AppValidators.validateOptionalBloodType,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: familyViewModel.allergiesController,
                      labelText: 'alergias_conocidas'.tr(),
                      hintText: 'ej_penicilina'.tr(),
                      icon: HugeIcons.strokeRoundedMedicalMask,
                      maxLines: 3,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'siguiente_paso'.tr(),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final currentAge =
                          _calculateAge(
                            familyViewModel.birthDateController.text,
                          ) ??
                          0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: familyViewModel,
                            child: FamilyVerificationScreen(
                              isMinor: currentAge < 18,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final primaryColor = AppColors.primaryColor(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withAlpha(30), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      Color.lerp(primaryColor, Colors.white, 0.3)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor(context),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withAlpha(20), Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
