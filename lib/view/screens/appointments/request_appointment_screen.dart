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

  String? _selectedSpecialty;
  String? _selectedHospital;
  final TextEditingController _reasonController = TextEditingController();
  int _currentStep = 0;

  final List<String> _specialties = [
    'Cardiología', 'Dermatología', 'Medicina General', 'Odontología', 'Pediatría'
  ];
  final List<String> _hospitals = [
    'Hospital Manolo Morales', 'Hospital Vélez Paiz', 'Centro de Salud Sócrates Flores', 'Centro Cardiológico Nacional'
  ];

  void _nextStepOrSummary() {
    bool isValid = false;
    String errorMessage = '';

    switch (_currentStep) {
      case 0:
        isValid = _selectedSpecialty != null;
        errorMessage = 'Por favor, selecciona una especialidad';
        break;
      case 1:
        isValid = _selectedHospital != null;
        errorMessage = 'Por favor, selecciona un hospital';
        break;
      case 2:
        isValid = _reasonController.text.isNotEmpty && _reasonController.text.length >= 10;
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
              specialty: _selectedSpecialty!,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          title: const Text('Solicitar Cita Médica'),
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: const Color.fromARGB(100, 0, 0, 0), // 👈 CORREGIDO
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppColors.textColor),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              AppointmentProgressIndicator(currentStep: _currentStep),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => _currentStep = page);
                  },
                  children: [
                    AppointmentStepLayout(
                      icon: HugeIcons.strokeRoundedMicroscope,
                      title: '¿Qué especialidad necesitas?',
                      subtitle: 'Selecciona la especialidad médica que necesitas consultar',
                      content: AppStyledDropdown(
                        value: _selectedSpecialty,
                        items: _specialties,
                        hintText: 'Selecciona una especialidad',
                        prefixIcon: HugeIcons.strokeRoundedMicroscope,
                        onChanged: (value) => setState(() => _selectedSpecialty = value),
                      ),
                    ),
                    AppointmentStepLayout(
                      icon: HugeIcons.strokeRoundedHospital01,
                      title: 'Elige tu centro médico',
                      subtitle: 'Selecciona el hospital o centro de salud de tu preferencia',
                      content: AppStyledDropdown(
                        value: _selectedHospital,
                        items: _hospitals,
                        hintText: 'Selecciona un hospital',
                        prefixIcon: HugeIcons.strokeRoundedHospital01,
                        onChanged: (value) => setState(() => _selectedHospital = value),
                      ),
                    ),
                    AppointmentStepLayout(
                      icon: HugeIcons.strokeRoundedNote,
                      title: 'Cuéntanos sobre tu consulta',
                      subtitle: 'Describe brevemente el motivo de tu visita médica',
                      content: CustomTextField(
                        controller: _reasonController,
                        focusNode: _reasonFocusNode,
                        labelText: 'Motivo de la consulta',
                        hintText: 'Ej: Dolor de cabeza, chequeo general, molestias...',
                        icon: HugeIcons.strokeRoundedNote,
                        maxLines: 5,
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
