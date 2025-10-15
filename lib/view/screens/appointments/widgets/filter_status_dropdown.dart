// lib/view/widgets/filters/filter_status_dropdown.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class FilterStatusDropdown extends StatelessWidget {
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;

  FilterStatusDropdown({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final List<String> _statusOptions = ['terminada', 'cancelada', 'no_asistio'];
  final Map<String, String> _statusDisplayNames = {
    'terminada': 'Terminada',
    'cancelada': 'Cancelada',
    'no_asistio': 'No Asistió',
  };

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'estado'.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              isExpanded: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                prefixIcon: Icon(
                  HugeIcons.strokeRoundedInformationCircle,
                  color: primaryColor,
                  size: 18.sp,
                ),
              ),
              hint: Text('seleccionar_estado'.tr()),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade600,
                size: 20.sp,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              items: _statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(
                    _statusDisplayNames[status]!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onStatusChanged,
            ),
          ),
        ),
      ],
    );
  }
}