import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';

class FilterHistoryModal extends StatefulWidget {
  final List<String> specialties;
  final Function(String specialty, DateTime? date, bool withResults) onApplyFilters;
  final VoidCallback onResetFilters;

  const FilterHistoryModal({
    super.key,
    required this.specialties,
    required this.onApplyFilters,
    required this.onResetFilters,
  });

  @override
  State<FilterHistoryModal> createState() => _FilterHistoryModalState();
}

class _FilterHistoryModalState extends State<FilterHistoryModal> {
  String? _selectedSpecialty;
  bool _withResultsOnly = false;
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.specialties.contains('Todas')) {
      _selectedSpecialty = 'Todas';
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  
    
  
  void _onDateTextChanged(String value) {
    if (_validateDate(value) == null && value.length == 10) {
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
        setState(() { _selectedDate = null; });
      }
    } else {
      setState(() { _selectedDate = null; });
    }
  }

  // 🔥 VALIDADOR DE FECHA LOCAL (CORREGIDO)
  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // El campo puede estar vacío, no es un error
    }
    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Formato: DD/MM/AAAA.';
    }
    try {
      DateFormat('dd/MM/yyyy').parseStrict(value);
      return null; // La fecha es válida
    } catch (e) {
      return 'Fecha no válida.';
    }
  }

  void _apply() {
    widget.onApplyFilters(_selectedSpecialty ?? 'Todas', _selectedDate, _withResultsOnly);
    Navigator.of(context).pop();
  }

  void _reset() {
    widget.onResetFilters();
    Navigator.of(context).pop();
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryColor, Color.lerp(primaryColor, Colors.white, 0.2)!]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(HugeIcons.strokeRoundedFilter, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('filtrar_historial'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textColor(context))),
                    Text('selecciona_los_criterios_de_bsqueda'.tr(), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSpecialtyDropdown(primaryColor),
                const SizedBox(height: 16),
                _buildDatePicker(primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: AppColors.warningColor(context)),
                  ),
                  child: Text('limpiar_filtros'.tr(), style: TextStyle(color: AppColors.warningColor(context), fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('aplicar'.tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyDropdown(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('especialidad'.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedSpecialty,
          items: widget.specialties.map((specialty) => DropdownMenuItem(value: specialty, child: Text(specialty))).toList(),
          onChanged: (value) => setState(() => _selectedSpecialty = value),
          decoration: InputDecoration(
            prefixIcon: Icon(HugeIcons.strokeRoundedStethoscope, color: primaryColor, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('fecha'.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  hintText: 'DD/MM/AAAA',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: Icon(HugeIcons.strokeRoundedCalendar01, color: primaryColor, size: 18),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(10), DateInputFormatter()],
                validator: _validateDate, // Se usa el validador local
                onChanged: _onDateTextChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}