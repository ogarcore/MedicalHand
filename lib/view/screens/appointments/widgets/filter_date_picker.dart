// lib/view/widgets/filters/filter_date_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class FilterDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onDateChanged;

  const FilterDatePicker({
    super.key,
    this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<FilterDatePicker> createState() => _FilterDatePickerState();
}

class _FilterDatePickerState extends State<FilterDatePicker> {
  late final TextEditingController _dateController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _selectedDate = widget.initialDate;
    if (_selectedDate != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final primaryColor = AppColors.primaryColor(context);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        widget.onDateChanged(_selectedDate);
      });
    }
  }

  void _onDateTextChanged(String value) {
    DateTime? newDate;
    if (AppValidators.validateBirthDate(value) == null) {
      try {
        final dateParts = value.split('/');
        newDate = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );
      } catch (e) {
        newDate = null;
      }
    } else {
      newDate = null;
    }
    setState(() {
      _selectedDate = newDate;
      widget.onDateChanged(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'fecha'.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  hintText: 'DD/MM/AAAA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: primaryColor, width: 1.5.w),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  prefixIcon: Icon(
                    HugeIcons.strokeRoundedCalendar01,
                    color: primaryColor,
                    size: 18.sp,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  DateInputFormatter(),
                ],
                validator: AppValidators.validateBirthDate,
                onChanged: _onDateTextChanged,
              ),
            ),
            SizedBox(width: 8.w),
            _buildPickerButton(primaryColor),
          ],
        ),
        if (_selectedDate != null) ...[
          SizedBox(height: 8.h),
          _buildConfirmationChip(),
        ],
      ],
    );
  }

  Widget _buildPickerButton(Color primaryColor) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withAlpha(204), primaryColor],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IconButton(
        onPressed: _pickDate,
        icon: Icon(
          HugeIcons.strokeRoundedCalendar01,
          color: Colors.white,
          size: 18.sp,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildConfirmationChip() {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Fecha seleccionada: ${DateFormat('d \'de\' MMMM, y', 'es_ES').format(_selectedDate!)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}