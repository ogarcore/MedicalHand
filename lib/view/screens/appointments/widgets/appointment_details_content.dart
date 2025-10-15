// lib/view/widgets/appointment/appointment_details_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';

class AppointmentDetailsContent extends StatelessWidget {
  final CitaModel cita;
  final String formattedDate;

  const AppointmentDetailsContent({
    super.key,
    required this.cita,
    required this.formattedDate,
  });

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primaryColor(context)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(context, HugeIcons.strokeRoundedStethoscope,
              'Especialidad', cita.specialty ?? 'No especificada'),
          _buildDetailRow(context, HugeIcons.strokeRoundedCalendar01,
              'Fecha y Hora', formattedDate),
          _buildDetailRow(context, HugeIcons.strokeRoundedHospital01, 'Hospital',
              cita.hospital),
          _buildDetailRow(context, HugeIcons.strokeRoundedDoctor01, 'Doctor',
              cita.assignedDoctor ?? 'No asignado'),
          _buildDetailRow(context, HugeIcons.strokeRoundedHospitalBed01,
              'Consultorio', cita.clinicOffice ?? 'No asignado'),
          _buildDetailRow(context, HugeIcons.strokeRoundedTask01,
              'Razón de Consulta', cita.reason),
        ],
      ),
    );
  }
}