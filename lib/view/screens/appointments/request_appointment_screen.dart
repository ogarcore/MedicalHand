import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/hospital_model.dart';
import 'package:p_hn25/view/widgets/custom_dropdown.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:provider/provider.dart';
import 'appointment_summary_screen.dart';
import 'widgets/appointment_progress_indicator.dart';
import 'widgets/appointment_step_layout.dart';
import 'widgets/appointment_navigation_bar.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';

class RequestAppointmentScreen extends StatefulWidget {
  const RequestAppointmentScreen({super.key});

  @override
  State<RequestAppointmentScreen> createState() =>
      _RequestAppointmentScreenState();
}

class _RequestAppointmentScreenState extends State<RequestAppointmentScreen> {
  final _pageController = PageController();
  final _reasonFocusNode = FocusNode();

  String? _selectedDepartament;
  HospitalModel? _selectedHospital;
  final TextEditingController _reasonController = TextEditingController();
  int _currentStep = 0;

  List<String> _departmentsList = [];
  List<HospitalModel> _hospitalsList = [];
  bool _isLoadingDepartments = true;
  bool _isLoadingHospitals = false;

  @override
  void initState() {
    super.initState();
    _reasonFocusNode.addListener(_onFocusChange);
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
    final departments = viewModel.getNicaraguaDepartments();
    if (mounted) {
      setState(() {
        _departmentsList = departments;
        _isLoadingDepartments = false;
      });
    }
  }

  Future<void> _fetchHospitalsForDepartment(String department) async {
    setState(() {
      _isLoadingHospitals = true;
      _hospitalsList = [];
      _selectedHospital = null;
    });

    final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
    final hospitals = await viewModel.getHospitals(department);

    if (mounted) {
      setState(() {
        _hospitalsList = hospitals;
        _isLoadingHospitals = false;
      });
    }
  }

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
              hospitalId: _selectedHospital!.id,
              hospitalName: _selectedHospital!.name,
              reason: _reasonController.text,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.warningColor(context),
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

  Future<bool> _showExitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomModal(
          icon: HugeIcons.strokeRoundedUserWarning01,
          title: '¿Salir del formulario?',
          content: const Text(
            'Si sales ahora, se perderán los datos que has ingresado.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          actions: <Widget>[
            ModalButton(
              text: 'Cancelar',
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ModalButton(
              text: 'Salir',
              isWarning: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _onWillPop() async {
    if (_currentStep > 0) {
      _previousStep();
      return false;
    } else {
      return await _showExitConfirmationDialog();
    }
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
    _pageController.dispose();
    _reasonFocusNode.removeListener(_onFocusChange);
    _reasonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
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
                    AppColors.primaryColor(context).withAlpha(243),
                    AppColors.primaryColor(context).withAlpha(217),
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
          body: _isLoadingDepartments
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  child: Column(
                    children: [
                      AppointmentProgressIndicator(
                        currentStep: _currentStep,
                        activeColor: AppColors.primaryColor(context),
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
                              iconColor: AppColors.primaryColor(context),
                              content: AppStyledDropdown(
                                value: _selectedDepartament,
                                items: _departmentsList,
                                hintText: 'Selecciona tú departamento',
                                prefixIcon: HugeIcons.strokeRoundedLocation04,
                                iconColor: AppColors.accentColor(context),
                                iconBackgroundColor: AppColors.accentColor(
                                  context,
                                ).withAlpha(30),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedDepartament = value;
                                    });
                                    _fetchHospitalsForDepartment(value);
                                  }
                                },
                              ),
                            ),
                            AppointmentStepLayout(
                              icon: HugeIcons.strokeRoundedHospital01,
                              title: 'Elige tu centro médico',
                              subtitle:
                                  'Elige el centro médico donde deseas agendar tu cita',
                              content: _buildHospitalsDropdown(),
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
                                iconColor: AppColors.accentColor(context),
                                focusedBorderColor: AppColors.accentColor(
                                  context,
                                ),
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
      ),
    );
  }

  Widget _buildHospitalsDropdown() {
    if (_selectedDepartament == null) {
      return AppStyledDropdown(
        items: const [],
        hintText: 'Selecciona un departamento primero',
        onChanged: (value) {},
        value: null,
        prefixIcon: HugeIcons.strokeRoundedHospital01,
      );
    }
    if (_isLoadingHospitals) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hospitalsList.isEmpty) {
      return AppStyledDropdown(
        items: const [],
        hintText: 'No se encontraron Hospitales',
        onChanged: (value) {},
        value: null,
        prefixIcon: HugeIcons.strokeRoundedHospital01,
        showDropdownIcon: false,
      );
    }
    return AppStyledDropdown(
      value: _selectedHospital?.name,
      items: _hospitalsList.map((hospital) => hospital.name).toList(),
      hintText: 'Selecciona un hospital',
      prefixIcon: HugeIcons.strokeRoundedHospital01,
      onChanged: (selectedName) {
        setState(() {
          _selectedHospital = _hospitalsList.firstWhere(
            (hospital) => hospital.name == selectedName,
          );
        });
      },
    );
  }
}
