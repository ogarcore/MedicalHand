import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Necesario para GeoPoint
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'appointment_summary_screen.dart';
import 'widgets/appointment_step_layout.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';

class RequestAppointmentScreen extends StatefulWidget {
  const RequestAppointmentScreen({super.key});

  @override
  State<RequestAppointmentScreen> createState() =>
      _RequestAppointmentScreenState();
}

class _RequestAppointmentScreenState extends State<RequestAppointmentScreen> {
  final _reasonFocusNode = FocusNode();
  final TextEditingController _reasonController = TextEditingController();

  // --- DATOS HARDCODEADOS DE LA CLÍNICA SIERRA MAESTRA ---
  final String _fixedCity = "Managua";
  final String _fixedHospitalId = "CA_SIERRA_MAESTRA";
  final String _fixedHospitalName = "Clinica Sierra Maestra";
  // Nota: Longitud Oeste (W) es negativa
  final GeoPoint _fixedLocation = const GeoPoint(12.096785257427769, -86.30226608465861); 

  @override
  void initState() {
    super.initState();
    _reasonFocusNode.addListener(_onFocusChange);
  }

  void _navigateToSummary() {
    // Solo validamos el motivo, ya que la clínica es automática
    bool isValid = _reasonController.text.isNotEmpty &&
        _reasonController.text.length >= 10;
    
    String errorMessage = _reasonController.text.isEmpty
        ? 'por_favor_describe_el_motivo_de_tu_consulta'.tr()
        : 'por_favor_proporciona_más_detalles'.tr();

    if (isValid) {
      // Navegación directa al resumen con los datos inyectados
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentSummaryScreen(
            departament: _fixedCity,
            hospitalId: _fixedHospitalId,
            hospitalName: _fixedHospitalName,
            location: _fixedLocation,
            reason: _reasonController.text,
          ),
        ),
      );
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

  Future<bool> _showExitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomModal(
          icon: HugeIcons.strokeRoundedUserWarning01,
          title: 'salir_del_formulario'.tr(),
          content: Text(
            'si_sales_ahora_se_perdern_los_datos_que_has_ingresado'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          actions: <Widget>[
            ModalButton(
              text: 'cancelar'.tr(),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ModalButton(
              text: 'salir'.tr(),
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
    // Si hay texto escrito, pedimos confirmación antes de salir
    if (_reasonController.text.isNotEmpty) {
       return await _showExitConfirmationDialog();
    }
    return true;
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
    _reasonFocusNode.removeListener(_onFocusChange);
    _reasonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop) {
            if (!context.mounted) return;
            Navigator.of(context).pop();
          }
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          appBar: AppBar(
            title: Text(
              'solicitar_cita_mdica'.tr(),
              style: const TextStyle(
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
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20),
                  child: AppointmentStepLayout(
                    icon: HugeIcons.strokeRoundedNote,
                    title: 'cuntanos_sobre_tu_consulta'.tr(),
                    subtitle: 'describe_brevemente_el_motivo_de_tu_visita_mdica'.tr(),
                    iconColor: AppColors.primaryColor(context),
                    content: CustomTextField(
                      controller: _reasonController,
                      focusNode: _reasonFocusNode,
                      labelText: 'motivo_de_la_consulta'.tr(),
                      hintText: 'ej_dolor_de_cabeza_chequeo_general_molestias'.tr(),
                      icon: HugeIcons.strokeRoundedNote,
                      maxLines: 8, // Aumenté un poco las líneas para que se vea mejor solo
                      iconColor: AppColors.accentColor(context),
                      focusedBorderColor: AppColors.accentColor(context),
                    ),
                  ),
                ),
              ),
              // Botón de Continuar fijo abajo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor(context),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _navigateToSummary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor(context),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'continuar'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}