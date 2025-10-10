import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final Color? iconColor;
  final Color? focusedBorderColor;
  final ValueChanged<String>? onChanged;
  // 🔥 1. AÑADIDO EL NUEVO PARÁMETRO OPCIONAL (NULLABLE)
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.minLines,
    this.maxLines,
    this.iconColor,
    this.focusedBorderColor,
    this.onChanged,
    // 🔥 2. AÑADIDO AL CONSTRUCTOR
    this.suffixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _hasFocus = widget.focusNode?.hasFocus ?? false;
      });
    }
  }

  TextCapitalization _getTextCapitalization() {
    if (widget.isPassword ||
        widget.keyboardType == TextInputType.emailAddress ||
        widget.keyboardType == TextInputType.visiblePassword ||
        widget.keyboardType == TextInputType.url) {
      return TextCapitalization.none;
    }
    return TextCapitalization.sentences;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode,
      autofocus: false,
      controller: widget.controller,
      obscureText: widget.isPassword && _isObscured,
      keyboardType: widget.keyboardType,
      textCapitalization: _getTextCapitalization(),
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      minLines: widget.isPassword ? 1 : 1,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textColor(context),
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: _hasFocus ? Colors.grey[700] : Colors.grey[600],
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        prefixIcon: Icon(
          widget.icon,
          color: widget.iconColor ?? AppColors.primaryColor(context),
          size: 22,
        ),
        // 🔥 3. LÓGICA ACTUALIZADA PARA EL SUFFIXICON
        // Prioridad 1: Si se pasa un suffixIcon personalizado, úsalo.
        // Prioridad 2: Si no, y es un campo de contraseña, usa el botón de visibilidad.
        // Prioridad 3: Si no es ninguna de las anteriores, no muestres nada (null).
        suffixIcon: widget.suffixIcon != null
            ? widget.suffixIcon
            : widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: widget.iconColor ?? AppColors.primaryColor(context),
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent, width: 0.6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 0.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? AppColors.primaryColor(context),
            width: 1.8,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(180),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}