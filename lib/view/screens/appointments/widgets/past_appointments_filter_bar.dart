import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/data/models/cita_model.dart';

class AppointmentFilters {
  final DateTime? date;
  final String? status;

  AppointmentFilters({this.date, this.status});

  bool get hasActiveFilters => date != null || status != null;
}

class PastAppointmentsFilterBar extends StatefulWidget {
  final List<CitaModel> allAppointments;
  final AppointmentFilters currentFilters;
  final Function(AppointmentFilters) onFiltersChanged;

  const PastAppointmentsFilterBar({
    super.key,
    required this.allAppointments,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<PastAppointmentsFilterBar> createState() => PastAppointmentsFilterBarState();
}

class PastAppointmentsFilterBarState extends State<PastAppointmentsFilterBar> {
  
  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _FilterBottomSheet(
          initialFilters: widget.currentFilters,
          onApply: (newFilters) {
            widget.onFiltersChanged(newFilters);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final AppointmentFilters initialFilters;
  final Function(AppointmentFilters) onApply;

  const _FilterBottomSheet({
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  DateTime? _selectedDate;
  String? _selectedStatus;
  final TextEditingController _dateController = TextEditingController();

  final List<String> _statusOptions = ['terminada', 'cancelada', 'no_asistio'];
  final Map<String, String> _statusDisplayNames = {
    'terminada': 'Terminada',
    'cancelada': 'Cancelada',
    'no_asistio': 'No Asistió',
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialFilters.date;
    _selectedStatus = widget.initialFilters.status;
    if (_selectedDate != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    }
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
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _onDateTextChanged(String value) {
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

  void _applyFilters() {
    final newFilters = AppointmentFilters(
      date: _selectedDate,
      status: _selectedStatus,
    );
    widget.onApply(newFilters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedDate = null;
      _selectedStatus = null;
      _dateController.clear();
    });
    final clearedFilters = AppointmentFilters();
    widget.onApply(clearedFilters);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    final backgroundColor = AppColors.backgroundColor(context);
    
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header compacto
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      Color.lerp(primaryColor, Colors.white, 0.2)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(HugeIcons.strokeRoundedFilter, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filtrar Citas Pasadas', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textColor(context))),
                    Text('Selecciona los criterios',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Contenido compacto
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDatePicker(primaryColor),
                const SizedBox(height: 16),
                _buildStatusDropdown(primaryColor),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botones compactos
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Text('Limpiar', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text('Aplicar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDatePicker(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fecha', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  hintText: 'DD/MM/AAAA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: Icon(HugeIcons.strokeRoundedCalendar01, color: primaryColor, size: 18),
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
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.8),
                    primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _pickDate,
                icon: Icon(HugeIcons.strokeRoundedCalendar01, color: Colors.white, size: 18),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        if (_selectedDate != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fecha seleccionada: ${DateFormat('d \'de\' MMMM, y', 'es_ES').format(_selectedDate!)}',
                    style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusDropdown(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              isExpanded: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                prefixIcon: Icon(HugeIcons.strokeRoundedInformationCircle, color: primaryColor, size: 18),
              ),
              hint: const Text('Seleccionar estado'),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              menuMaxHeight: 200,
              items: _statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(
                    _statusDisplayNames[status]!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}