import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class EditFamilyMemberInfoScreen extends StatefulWidget {
  // Se recibe un 'member' en lugar de 'user' para mayor claridad
  final UserModel member;
  const EditFamilyMemberInfoScreen({super.key, required this.member});

  @override
  State<EditFamilyMemberInfoScreen> createState() => _EditFamilyMemberInfoScreenState();
}

class _EditFamilyMemberInfoScreenState extends State<EditFamilyMemberInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para todos los campos editables
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isLoading = false;

  // Funciones helper para formatear los valores iniciales
  String _formatInitialCedula(String rawText) {
    if (rawText.length != 14) return rawText;
    final buffer = StringBuffer();
    for (int i = 0; i < rawText.length; i++) {
      buffer.write(rawText[i]);
      if ((i == 2 || i == 8) && i < rawText.length - 1) {
        buffer.write('-');
      }
    }
    return buffer.toString().toUpperCase();
  }

  String _formatInitialPhone(String rawText) {
    if (rawText.length != 8) return rawText;
    return '${rawText.substring(0, 4)}-${rawText.substring(4)}';
  }

  @override
  void initState() {
    super.initState();
    // Se inicializan los controladores con los datos del 'member'
    _firstNameController = TextEditingController(text: widget.member.firstName);
    _lastNameController = TextEditingController(text: widget.member.lastName);
    _addressController = TextEditingController(text: widget.member.address);
    _idNumberController = TextEditingController(text: _formatInitialCedula(widget.member.idNumber));
    _phoneController = TextEditingController(text: _formatInitialPhone(widget.member.phoneNumber));

    try {
      final date = widget.member.dateOfBirth.toDate();
      _dobController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(date),
      );
    } catch (e) {
      _dobController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idNumberController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Lógica para guardar los datos actualizados del familiar
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final Map<String, dynamic> updatedData = {
      'personalInfo.firstName': _firstNameController.text.trim(),
      'personalInfo.lastName': _lastNameController.text.trim(),
      'personalInfo.idNumber': _idNumberController.text, 
      'contactInfo.phoneNumber': _phoneController.text, 
      'contactInfo.address': _addressController.text.trim(),
    };

    try {
      final dateText = _dobController.text.trim();
      if (dateText.isNotEmpty) {
        final parsedDate = DateFormat('dd/MM/yyyy').parseLoose(dateText);
        updatedData['personalInfo.dateOfBirth'] = Timestamp.fromDate(parsedDate);
      }
    } catch (e) {
//
    }

    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    // *** CAMBIO CLAVE: Se llama a la función para actualizar el familiar ***
    final success = await viewModel.updateFamilyMemberProfile(widget.member.uid, updatedData);

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Información actualizada con éxito.'
              : 'Error al actualizar. Inténtalo de nuevo.',
        ),
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          // Título adaptado para el contexto de familiar
          title: Text('editar_info_familiar'.tr()),
          backgroundColor: AppColors.accentColor(context),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentColor(context).withAlpha(26),
                      AppColors.accentColor(context).withAlpha(13),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentColor(context).withAlpha(51),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentColor(context),
                            AppColors.accentColor(context).withAlpha(204),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentColor(
                              context,
                            ).withAlpha(77),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // Texto del header adaptado
                            'editar_datos_de'.tr(args: [widget.member.firstName]),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentColor(context),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'mantn_sus_datos_actualizados'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(16),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 600;
                              return isWide
                                  ? _buildWideLayout()
                                  : _buildCompactLayout();
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: PrimaryButton(
                              text: 'guardar_cambios'.tr(),
                              onPressed: _handleSave,
                              isLoading: _isLoading,
                              backgroundColor: AppColors.accentColor(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      children: [
        _buildTextFieldEnhanced(
          controller: _firstNameController,
          labelText: 'nombres'.tr(),
          hintText: 'ingresa_sus_nombres'.tr(),
          icon: HugeIcons.strokeRoundedUser,
          validator: (value) =>
              AppValidators.validateGenericEmpty(value, 'nombres'.tr()),
        ),
        const SizedBox(height: 20),
        _buildTextFieldEnhanced(
          controller: _lastNameController,
          labelText: 'apellidos'.tr(),
          hintText: 'ingresa_sus_apellidos'.tr(),
          icon: HugeIcons.strokeRoundedUserCircle,
          validator: (value) =>
              AppValidators.validateGenericEmpty(value, 'apellidos'.tr()),
        ),
        const SizedBox(height: 20),
        _buildTextFieldEnhanced(
          controller: _idNumberController,
          labelText: 'cdula_de_identidad'.tr(),
          hintText: 'nmero_de_cdula'.tr(),
          icon: HugeIcons.strokeRoundedPassport,
          keyboardType: TextInputType.visiblePassword,
          inputFormatters: [
            LengthLimitingTextInputFormatter(16),
            CedulaInputFormatter(),
          ],
          validator: AppValidators.validateCedula,
        ),
        const SizedBox(height: 20),
        _buildTextFieldEnhanced(
          controller: _dobController,
          labelText: 'fecha_de_nacimiento'.tr(),
          hintText: 'dd/MM/yyyy',
          icon: HugeIcons.strokeRoundedCalendar02,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            DateInputFormatter(),
          ],
          validator: AppValidators.validateBirthDate,
        ),
        const SizedBox(height: 20),
        _buildTextFieldEnhanced(
          controller: _phoneController,
          labelText: 'telfono'.tr(),
          hintText: 'nmero_de_telfono'.tr(),
          icon: HugeIcons.strokeRoundedFlipPhone,
          inputFormatters: [PhoneInputFormatter()],
          keyboardType: TextInputType.phone,
          validator: AppValidators.validatePhone,
        ),
        const SizedBox(height: 20),
        _buildTextFieldEnhanced(
          controller: _addressController,
          labelText: 'direccin'.tr(),
          hintText: 'direccin_de_domicilio'.tr(),
          icon: HugeIcons.strokeRoundedLocation03,
          minLines: 1,
          maxLines: 3,
          validator: (value) =>
              AppValidators.validateGenericEmpty(value, 'La dirección'),
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildTextFieldEnhanced(
                    controller: _firstNameController,
                    labelText: 'nombres'.tr(),
                    hintText: 'ingresa_sus_nombres'.tr(),
                    icon: Icons.person_outline_rounded,
                    validator: (value) =>
                        AppValidators.validateGenericEmpty(value, 'nombres'.tr()),
                  ),
                  const SizedBox(height: 20),
                  _buildTextFieldEnhanced(
                    controller: _idNumberController,
                    labelText: 'cdula_de_identidad'.tr(),
                    hintText: 'nmero_de_cdula'.tr(),
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(16),
                      CedulaInputFormatter(),
                    ],
                    validator: AppValidators.validateCedula,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFieldEnhanced(
                    controller: _phoneController,
                    labelText: 'telfono'.tr(),
                    hintText: 'nmero_de_telfono'.tr(),
                    icon: Icons.phone_outlined,
                    inputFormatters: [PhoneInputFormatter()],
                    keyboardType: TextInputType.phone,
                    validator: AppValidators.validatePhone,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  _buildTextFieldEnhanced(
                    controller: _lastNameController,
                    labelText: 'apellidos'.tr(),
                    hintText: 'ingresa_sus_apellidos'.tr(),
                    icon: Icons.person_outline_rounded,
                    validator: (value) =>
                        AppValidators.validateGenericEmpty(value, 'apellidos'.tr()),
                  ),
                  const SizedBox(height: 20),
                  _buildTextFieldEnhanced(
                    controller: _dobController,
                    labelText: 'fecha_de_nacimiento'.tr(),
                    hintText: 'dd/MM/yyyy',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      DateInputFormatter(),
                    ],
                    validator: AppValidators.validateBirthDate,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFieldEnhanced(
                    controller: _addressController,
                    labelText: 'direccin'.tr(),
                    hintText: 'direccin_de_domicilio'.tr(),
                    icon: Icons.location_on_outlined,
                    minLines: 1,
                    maxLines: 3,
                    validator: (value) => AppValidators.validateGenericEmpty(
                      value,
                      'La dirección',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFieldEnhanced({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int? minLines,
    int? maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onTap: onTap,
        inputFormatters: inputFormatters,
        minLines: minLines,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: TextStyle(
            color: AppColors.accentColor(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentColor(context).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.accentColor(context)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.accentColor(context),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        validator: validator,
      ),
    );
  }
}