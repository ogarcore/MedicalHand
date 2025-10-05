// lib/view/widgets/custom_dropdown.dart
import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';

class AppStyledDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final IconData prefixIcon;
  final FormFieldValidator<String>? validator;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool showDropdownIcon;

  const AppStyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
    this.iconColor,
    this.iconBackgroundColor,
    this.showDropdownIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primaryColor(context);
    final effectiveIconBg =
        iconBackgroundColor ?? AppColors.primaryColor(context).withAlpha(25);

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
                color: AppColors.primaryColor(context).withAlpha(25),
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
                validator: validator,
                initialValue: value,
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String v) {
                  return DropdownMenuItem<String>(
                    value: v,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 100),
                      child: Text(
                        v,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines:
                            2, // Permite hasta 2 líneas para textos largos
                      ),
                    ),
                  );
                }).toList(),

                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((String item) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      constraints: const BoxConstraints(minWidth: 100),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines:
                            1, // Para el campo seleccionado, solo una línea con puntos suspensivos
                      ),
                    );
                  }).toList();
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 12,
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    prefixIcon,
                    color: effectiveIconColor,
                    size: 22,
                  ),
                  isDense: true,
                ),
                dropdownColor: Colors.white,
                icon: showDropdownIcon
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: effectiveIconBg,
                        ),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: effectiveIconColor,
                          size: 24,
                        ),
                      )
                    : const SizedBox.shrink(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor(context),
                ),
                borderRadius: BorderRadius.circular(16),
                isExpanded: true,
                menuMaxHeight: 300,
                elevation: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
