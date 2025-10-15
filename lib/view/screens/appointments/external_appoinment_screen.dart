import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/appointments/external_appointment_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/hospital_model.dart';
import 'package:p_hn25/view/widgets/custom_dropdown.dart';
import 'appointment_summary_screen.dart';
import 'widgets/appointment_progress_indicator.dart';
import 'widgets/appointment_step_layout.dart';
import 'widgets/appointment_navigation_bar.dart';

class ExternalAppoinmentScreen extends StatefulWidget {
  const ExternalAppoinmentScreen({super.key});

  @override
  State<ExternalAppoinmentScreen> createState() =>
      _ExternalAppoinmentScreenState();
}

class _ExternalAppoinmentScreenState extends State<ExternalAppoinmentScreen> {
  final _pageController = PageController();
  bool _isPickerActive = false;
  // --- ESTADOS PARA LOS 3 PASOS ---
  File? _referralImage;
  bool _isDigitalReferral =
      false; // Nuevo estado para saber qué opción se eligió
  String? _selectedSpecialty;

  String? _selectedDepartment;
  HospitalModel? _selectedHospital;

  int _currentStep = 0;

  // --- LISTAS DE DATOS ---
  final List<String> _specialties = [
    'Cardiología',
    'Dermatología',
    'Endocrinología',
    'Gastroenterología',
    'Neurología',
  ];
  final List<String> _departments = [
    'Boaco',
    'Chinandega',
    'Estelí',
    'Jinotepe',
    'Jinotega',
    'Managua',
  ];
  final List<HospitalModel> _hospitalsList = [];

  Future<void> _pickImage() async {
    // 1. Si ya está activo, no hagas nada.
    if (_isPickerActive) return;

    try {
      // 2. Levanta la bandera para bloquear nuevos clics.
      setState(() {
        _isPickerActive = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        setState(() {
          _referralImage = File(image.path);
          _isDigitalReferral = false;
        });
      }
    } finally {
      // 3. Baja la bandera para permitir clics de nuevo, pase lo que pase.
      if (mounted) {
        setState(() {
          _isPickerActive = false;
        });
      }
    }
  }

  void _selectDigitalReferral() {
    setState(() {
      _isDigitalReferral = true;
      _referralImage =
          null; // Se asegura que la opción de imagen esté desactivada
    });
  }

  void _resetReferralChoice() {
    setState(() {
      _referralImage = null;
      _isDigitalReferral = false;
      _selectedSpecialty = null; // También reinicia la especialidad
    });
  }

  void _nextStepOrSummary() {
    bool isValid = false;
    String errorMessage = '';

    switch (_currentStep) {
      case 0: // La validación ahora comprueba si se eligió foto O referencia digital
        final hasReferral = _referralImage != null || _isDigitalReferral;
        if (!hasReferral) {
          errorMessage = 'Por favor, adjunta tu referencia';
        } else if (_selectedSpecialty == null) {
          errorMessage = 'Por favor, selecciona la especialidad';
        } else {
          isValid = true;
        }
        break;
      case 1:
        isValid = _selectedDepartment != null;
        errorMessage = 'Por favor, selecciona tu departamento';
        break;
      case 2:
        isValid = _selectedHospital != null;
        errorMessage = 'Por favor, selecciona un hospital';
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
              referralImage: _referralImage,
              specialty: _selectedSpecialty,
              departament: _selectedDepartment!,
              hospitalId: _selectedHospital!.id,
              hospitalName: _selectedHospital!.name,
              location: _selectedHospital!.location,
              reason: "Cita solicitada por referencia",
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasReferral = _referralImage != null || _isDigitalReferral;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          title: Text(
            'referencia_externa'.tr(),
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
                  AppColors.accentColor(context).withAlpha(243),
                  AppColors.accentColor(context).withAlpha(217),
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

        body: Column(
          children: [
            AppointmentProgressIndicator(
              currentStep: _currentStep,
              stepTitles: const ['Referencia', 'Ubicación', 'Hospital'],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentStep = page),
                children: [
                  // --- PASO 1: ADJUNTAR REFERENCIA Y ESPECIALIDAD ---
                  AppointmentStepLayout(
                    icon: HugeIcons.strokeRoundedDocumentValidation,
                    iconColor: AppColors.accentColor(context),
                    title: 'adjunta_tu_referencia'.tr(),
                    subtitle: 'selecciona_una_referencia_digital'.tr(),
                    content: Column(
                      children: [
                        // Si no se ha elegido nada, muestra las dos opciones
                        if (!hasReferral)
                          _buildReferralOptions()
                        // Si se eligió una, muestra la confirmación
                        else
                          _buildAttachmentConfirmation(),

                        // El dropdown de especialidad aparece si ya se adjuntó algo
                        if (hasReferral) ...[
                          const SizedBox(height: 16),
                          AppStyledDropdown(
                            value: _selectedSpecialty,
                            items: _specialties,
                            hintText: 'selecciona_la_especialidad'.tr(),
                            prefixIcon: HugeIcons.strokeRoundedStethoscope,
                            onChanged: (value) =>
                                setState(() => _selectedSpecialty = value),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // --- PASO 2: UBICACIÓN ---
                  AppointmentStepLayout(
                    icon: HugeIcons.strokeRoundedLocation04,
                    iconColor: AppColors.accentColor(context),
                    title: '¿En qué departamento te encuentras?',
                    subtitle:
                        'selecciona_tu_ubicacin_para_mostrarte_los_hospitales'.tr(),
                    content: AppStyledDropdown(
                      value: _selectedDepartment,
                      items: _departments,
                      hintText: 'selecciona_tu_departamento'.tr(),
                      prefixIcon: HugeIcons.strokeRoundedLocation04,
                      onChanged: (value) =>
                          setState(() => _selectedDepartment = value),
                    ),
                  ),
                  // --- PASO 3: HOSPITAL ---
                  AppointmentStepLayout(
                    icon: HugeIcons.strokeRoundedHospital01,
                    iconColor: AppColors.accentColor(context),
                    title: 'confirma_el_centro_mdico'.tr(),
                    subtitle:
                        'verifica_el_hospital_de_destino_que_indica_tu_referencia'.tr(),
                    content: AppStyledDropdown(
                      value: _selectedHospital?.name,
                      // Mapeamos nuestra lista de objetos a una lista de Strings para mostrar
                      items: _hospitalsList
                          .map((hospital) => hospital.name)
                          .toList(),
                      hintText: 'selecciona_un_hospital'.tr(),
                      prefixIcon: HugeIcons.strokeRoundedHospital01,
                      onChanged: (selectedName) {
                        setState(() {
                          // ...buscamos en nuestra lista completa el objeto HospitalModel que coincide
                          _selectedHospital = _hospitalsList.firstWhere(
                            (hospital) => hospital.name == selectedName,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppointmentNavigationBar(
          currentStep: _currentStep,
          onNextPressed: _nextStepOrSummary,
          onPreviousPressed: _previousStep,
          primaryColor: AppColors.accentColor(context),
          secondaryColor: AppColors.accentColor(context),
          secondarySide: BorderSide(
            color: AppColors.accentColor(context),
            width: 1,
          ),
          secondaryForegroundColor: AppColors.accentColor(context),
          secondaryIconColor: AppColors.accentColor(context),
          secondaryShadowColor: AppColors.accentColor(context).withAlpha(35),
        ),
      ),
    );
  }

  // Muestra las dos opciones: subir foto o adjuntar digital
  Widget _buildReferralOptions() {
    return Column(
      children: [
        // Botón para subir foto
        _buildOptionCard(
          icon: HugeIcons.strokeRoundedCamera01,
          title: 'subir_foto_de_referencia'.tr(),
          subtitle: 'toma_o_selecciona_una_foto_de_tu_galera'.tr(),
          onTap: _pickImage,
        ),
        const SizedBox(height: 12),
        // Botón para referencia digital
        _buildOptionCard(
          icon: HugeIcons.strokeRoundedInbox,
          title: 'referencia_digital'.tr(),
          subtitle: 'selecciona_de_tu_bandeja_de_entrada'.tr(),
          onTap: _selectDigitalReferral,
        ),
      ],
    );
  }

  // Muestra el mensaje de confirmación dependiendo de la opción elegida
  Widget _buildAttachmentConfirmation() {
    final bool isImage = _referralImage != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successColor(context).withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.successColor(context).withAlpha(60),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Muestra el thumbnail de la foto o un ícono genérico
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.successColor(context).withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _referralImage!,
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    HugeIcons.strokeRoundedFolder01,
                    color: AppColors.successColor(context),
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isImage ? "Foto cargada" : 'referencia_digital'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isImage
                      ? "Referencia adjuntada correctamente"
                      : 'seleccionada_de_tu_bandeja'.tr(),
                  style: TextStyle(
                    color: AppColors.textLightColor(context),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.textLightColor(context).withAlpha(150),
              size: 18,
            ),
            onPressed: _resetReferralChoice,
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para las tarjetas de opción
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.accentColor(context).withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.accentColor(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLightColor(context),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textLightColor(context).withAlpha(120),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
