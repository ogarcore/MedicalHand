// lib/view/widgets/custom_dropdown.dart
import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';

class AppStyledDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final IconData prefixIcon;
  // ----- INICIO DEL CAMBIO -----
  // 1. Se añade el validador como un parámetro opcional (nullable).
  final FormFieldValidator<String>? validator;
  // ----- FIN DEL CAMBIO -----

  const AppStyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    required this.prefixIcon,
    this.validator, // <-- Se añade al constructor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white.withAlpha(180),
                Colors.white.withAlpha(180),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withAlpha(25),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                // ----- INICIO DEL CAMBIO -----
                // 2. Se pasa el validador al widget interno.
                // Si es nulo, simplemente no se aplica ninguna validación.
                validator: validator,
                // ----- FIN DEL CAMBIO -----
                value: value, // Cambiado de initialValue a value para mejor manejo de estado
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String v) {
                  return DropdownMenuItem<String>(
                    value: v,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Text(
                            v,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 16,
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    prefixIcon,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                ),
                dropdownColor: Colors.white,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withAlpha(25),
                  ),
                  child: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
                borderRadius: BorderRadius.circular(16),
                isExpanded: true,
                menuMaxHeight: 200,
                elevation: 8,
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((String v) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            v,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}