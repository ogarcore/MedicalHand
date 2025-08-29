// lib/view/screens/appointments/request_appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/widgets/custom_dropdown.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'appointment_summary_screen.dart';

// Importa los nuevos widgets
import 'widgets/appointment_progress_indicator.dart';
import 'widgets/appointment_step_layout.dart';
import 'widgets/appointment_navigation_bar.dart';

class RequestAppointmentScreen extends StatefulWidget {
  const RequestAppointmentScreen({super.key});

  @override
  State<RequestAppointmentScreen> createState() =>
      _RequestAppointmentScreenState();
}

class _RequestAppointmentScreenState extends State<RequestAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final FocusNode _reasonFocusNode = FocusNode();

  String? _selectedDepartament;
  String? _selectedHospital;
  final TextEditingController _reasonController = TextEditingController();
  int _currentStep = 0;

  final List<String> _departaments = [
    'Boaco',
    'Chinandega',
    'Estelí',
    'Jinotepe',
    'Jinotega',
    'Managua',
  ];
  final List<String> _hospitals = [
    'Hospital Manolo Morales',
    'Hospital Vélez Paiz',
    'Centro de Salud Sócrates Flores',
    'Centro Cardiológico Nacional',
  ];

  void _nextStepOrSummary() {
    bool isValid = false;
    String errorMessage = '';

    switch (_currentStep) {
      case 0:
        isValid = _selectedDepartament != null;
        errorMessage = 'Por favor, selecciona tu departamento';
        break;
      case 1:
        isValid = _selectedHospital != null;
        errorMessage = 'Por favor, selecciona un hospital';
        break;
      case 2:
        isValid =
            _reasonController.text.isNotEmpty &&
            _reasonController.text.length >= 10;
        errorMessage = _reasonController.text.isEmpty
            ? 'Por favor, describe el motivo de tu consulta'
            : 'Por favor, proporciona más detalles (mínimo 10 caracteres)';
        break;
    }

    if (isValid) {
      if (_currentStep < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentSummaryScreen(
              departament: _selectedDepartament!,
              hospital: _selectedHospital!,
              reason: _reasonController.text,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _reasonFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_reasonFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _reasonFocusNode.context != null) {
          Scrollable.ensureVisible(
            _reasonFocusNode.context!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.4,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _pageController.removeListener(() {});
    _pageController.dispose();
    _reasonFocusNode.removeListener(_onFocusChange);
    _reasonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Solicitar Cita Médica',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor.withAlpha(243),
                  AppColors.primaryColor.withAlpha(217),
                ],
              ),
            ),
          ),
          elevation: 1,
          shadowColor: const Color.fromARGB(100, 0, 0, 0),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        body: Form(
          key: _formKey,
          child: Column(
            children: [
              AppointmentProgressIndicator(
                currentStep: _currentStep,
                activeColor: AppColors.primaryColor,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => _currentStep = page);
                  },
                  children: [
                    AppointmentStepLayout(
                      icon: HugeIcons.strokeRoundedLocation04,
                      title: '¿En qué departamento te encuentras?',
                      subtitle:
                          'Selecciona tu ubicación para mostrarte los hospital de tu zona',
                      iconColor: AppColors.primaryColor,
                      content: AppStyledDropdown(
                        value: _selectedDepartament,
                        items: _departaments,
                        hintText: 'Selecciona tú departamento',
                        prefixIcon: HugeIcons.strokeRoundedLocation04,
                        iconColor: AppColors.accentColor,
                        iconBackgroundColor: AppColors.accentColor.withAlpha(
                          30,
                        ),
                        onChanged: (value) =>
                            setState(() => _selectedDepartament = value),
                      ),
                    ),
                    AppointmentStepLayout(
                      icon: HugeIcons.strokeRoundedHospital01,
                      title: 'Elige tu centro médico',
                      subtitle:
                          'Elige el centro médico donde deseas agendar tu cita',
                      content: AppStyledDropdown(
                        value: _selectedHospital,
                        items: _hospitals,
                        hintText: 'Selecciona un hospital',
                        prefixIcon: HugeIcons.strokeRoundedHospital01,
                        iconColor: AppColors.accentColor,
                        iconBackgroundColor: AppColors.accentColor.withAlpha(
                          30,
                        ),
                        onChanged: (value) =>
                            setState(() => _selectedHospital = value),
                      ),
                    ),
                    AppointmentStepLayout(
                      icon: HugeIcons.strokeRoundedNote,
                      title: 'Cuéntanos sobre tu consulta',
                      subtitle:
                          'Describe brevemente el motivo de tu visita médica',
                      content: CustomTextField(
                        controller: _reasonController,
                        focusNode: _reasonFocusNode,
                        labelText: 'Motivo de la consulta',
                        hintText:
                            'Ej: Dolor de cabeza, chequeo general, molestias...',
                        icon: HugeIcons.strokeRoundedNote,

                        maxLines: 5,
                        iconColor: AppColors.accentColor,
                        focusedBorderColor: AppColors.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppointmentNavigationBar(
          currentStep: _currentStep,
          onNextPressed: _nextStepOrSummary,
          onPreviousPressed: _previousStep,
        ),
      ),
    );
  }
}
