import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart'; // Importado para el formato de fecha
import 'package:p_hn25/view/screens/registration/registration_step3_screen.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/view/widgets/gradient_background.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/utils/input_formatters.dart';
import '../../../app/core/utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import '../../widgets/custom_dropdown.dart';
import '../../../view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import '../welcome/welcome_screen.dart';

class RegistrationStep2Screen extends StatefulWidget {
  const RegistrationStep2Screen({super.key});

  @override
  State<RegistrationStep2Screen> createState() =>
      _RegistrationStep2ScreenState();
}

class _RegistrationStep2ScreenState extends State<RegistrationStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  
  // La lógica para el selector de fecha se mantiene aquí.
  DateTime? _selectedDate;

  void _pickDate() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final primaryColor = AppColors.primaryColor(context);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
        authViewModel.birthDateController.text =
            DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }
  
  void _onDateTextChanged(String value) {
    // Esta función actualiza el _selectedDate si el usuario escribe una fecha válida manualmente.
    if (AppValidators.validateBirthDate(value) == null) {
      try {
        final dateParts = value.split('/');
        final newDate = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );
        setState(() {
          _selectedDate = newDate;
        });
      } catch (e) {
        setState(() {
          _selectedDate = null;
        });
      }
    } else {
      setState(() {
        _selectedDate = null;
      });
    }
  }

  Future<void> _onWillPop() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) => CustomModal(
        icon: HugeIcons.strokeRoundedAlert01,
        title: '¿Estás seguro?',
        content: Text(
          'si_sales_ahora_perders_todo_el_progreso_del_registro'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          ModalButton(
            text: 'cancelar'.tr(),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ModalButton(
            text: 'salir'.tr(),
            isWarning: true,
            onPressed: () async {
              await authViewModel.cancelGoogleRegistration();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final secondaryColor = AppColors.secondaryColor(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: GradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _onWillPop,
                            icon: Icon(
                              Icons.arrow_back,
                              color: AppColors.textColor(context),
                              size: 26.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'datos_personales'.tr(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const RegistrationProgressIndicator(currentStep: 2),
                      const SizedBox(height: 32),
                      Text(
                        'ahora_cuntanos_sobre_ti'.tr(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: authViewModel.nameController,
                        labelText: 'nombres'.tr(),
                        hintText: 'ingresa_tus_nombres'.tr(),
                        icon: Icons.person,
                        validator: (value) => AppValidators.validateGenericEmpty(value, 'nombres'.tr()),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: authViewModel.lastNameController,
                        labelText: 'apellidos'.tr(),
                        hintText: 'ingresa_tus_apellidos'.tr(),
                        icon: Icons.person_outline,
                        validator: (value) => AppValidators.validateGenericEmpty(value, 'apellidos'.tr()),
                      ),
                      const SizedBox(height: 10),
                      Consumer<AuthViewModel>(
                        builder: (context, viewModel, child) {
                          return AppStyledDropdown(
                            value: viewModel.selectedSex,
                            items: const ['Masculino', 'Femenino', 'Otro'],
                            hintText: 'selecciona_tu_sexo'.tr(),
                            prefixIcon: Icons.favorite_outline,
                            onChanged: (String? newValue) {
                              viewModel.updateSelectedSex(newValue);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: authViewModel.birthDateController,
                        labelText: 'fecha_de_nacimiento'.tr(),
                        hintText: 'DD/MM/AAAA',
                        icon: HugeIcons.strokeRoundedCalendar01, // Icono de prefijo
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          DateInputFormatter(),
                        ],
                        validator: AppValidators.validateBirthDate,
                        onChanged: _onDateTextChanged, 
                        suffixIcon: IconButton(
                          icon: Icon(HugeIcons.strokeRoundedCalendar02, color: secondaryColor),
                          onPressed: _pickDate, 
                        ),
                      ),
                      
                      const SizedBox(height: 50),
                      PrimaryButton(
                        text: 'siguiente'.tr(),
                        onPressed: () {
                          if (authViewModel.selectedSex == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('por_favor_selecciona_tu_sexo'.tr()),
                                backgroundColor: AppColors.warningColor(context),
                              ),
                            );
                            return;
                          }
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistrationStep3Screen(),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}