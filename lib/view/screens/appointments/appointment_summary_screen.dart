import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/screens/home/home_screen.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class AppointmentSummaryScreen extends StatefulWidget {
  final File? referralImage;
  final String? specialty;
  final String departament;
  final String hospitalId;
  final String hospitalName;
  final String reason;

  const AppointmentSummaryScreen({
    super.key,
    required this.departament,
    required this.hospitalId,
    required this.hospitalName,
    required this.reason,
    this.referralImage,
    this.specialty,
  });

  @override
  State<AppointmentSummaryScreen> createState() =>
      _AppointmentSummaryScreenState();
}

class _AppointmentSummaryScreenState extends State<AppointmentSummaryScreen> {
  // 2. Estado para mostrar un loader en el botón mientras se envía
  bool _isSubmitting = false;

  /// 3. Función que construye y envía la solicitud a Firestore
  Future<void> _submitAppointment() async {
    setState(() {
      _isSubmitting = true;
    });

    // Obtenemos los ViewModels necesarios usando Provider
    final appointmentViewModel = Provider.of<AppointmentViewModel>(
      context,
      listen: false,
    );
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentUser = userViewModel.currentUser;

    // Verificación de seguridad por si no hay un usuario cargado
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se encontró información del usuario.'),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // Creamos el objeto CitaModel con los datos del usuario y del formulario
    final newAppointment = CitaModel(
      uid: currentUser.uid,
      fullName: '${currentUser.firstName} ${currentUser.lastName}',
      idNumber: currentUser.idNumber,
      dateOfBirth: currentUser.dateOfBirth
          .toDate(), // Convertimos el Timestamp a DateTime
      phoneNumber: currentUser.phoneNumber,
      idHospital: widget.hospitalId,
      hospital: widget.hospitalName,
      reason: widget.reason,
      requestTimestamp: DateTime.now(),
      // Los valores por defecto (status, requestType, isActive) se ponen automáticamente desde el modelo
    );

    // Enviamos la solicitud a través del ViewModel
    final success = await appointmentViewModel.submitAppointmentRequest(
      newAppointment,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Solicitud enviada con éxito!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(
            bottom:
                10, 
            left: 20,
            right: 20,
          ),
          duration: Duration(seconds: 3),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

      // Navegamos a la pantalla de inicio y eliminamos todas las rutas anteriores
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error al enviar la solicitud. Inténtalo de nuevo.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(
            bottom:
                10, 
            left: 20,
            right: 20,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Resumen de Cita',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(30),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textColor),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor.withAlpha(20),
                        border: Border.all(
                          color: AppColors.primaryColor.withAlpha(40),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        HugeIcons.strokeRoundedTask01,
                        size: 26,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '¡Revisa tu solicitud!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Confirma que los datos de tu cita son correctos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLightColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      icon: HugeIcons.strokeRoundedLocation04,
                      label: 'Departamento',
                      value: widget.departament,
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.grey.withAlpha(40)),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      icon: HugeIcons.strokeRoundedHospital01,
                      label: 'Centro Médico',
                      value: widget.hospitalName,
                    ),

                    if (widget.specialty != null &&
                        widget.specialty!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Divider(height: 1, color: Colors.grey.withAlpha(40)),
                      const SizedBox(height: 16),
                      _buildSummaryRow(
                        icon: HugeIcons.strokeRoundedStethoscope,
                        label: 'Especialidad Solicitada',
                        value: widget.specialty!,
                      ),
                    ],

                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.grey.withAlpha(40)),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      icon: HugeIcons.strokeRoundedNote,
                      label: 'Motivo de Consulta',
                      value: widget.reason,
                      isMultiline: true,
                    ),

                    if (widget.referralImage != null) ...[
                      const SizedBox(height: 16),
                      Divider(height: 1, color: Colors.grey.withAlpha(40)),
                      const SizedBox(height: 16),
                      _buildSummaryImageRow(context, widget.referralImage!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Confirmar Solicitud',
                  isLoading:
                      _isSubmitting, // El botón mostrará un loader si está enviando
                  onPressed: _submitAppointment, // Llama a la función de envío
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryImageRow(BuildContext context, File image) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withAlpha(15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            HugeIcons.strokeRoundedImage01,
            color: AppColors.primaryColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foto de Referencia Adjunta',
                style: TextStyle(
                  color: AppColors.textLightColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(10),
                      child: InteractiveViewer(
                        panEnabled: false,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4,
                        child: Image.file(image),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Hero(
                  tag: 'referralImage',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withAlpha(15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textLightColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: isMultiline ? 1.3 : 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
