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
  final bool obscureText; // ✅ Nuevo parámetro opcional
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final Color? iconColor;
  final Color? focusedBorderColor;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false, // ✅ Valor por defecto
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.minLines,
    this.maxLines,
    this.iconColor,
    this.focusedBorderColor,
    this.onChanged,
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
        widget.obscureText ||
        widget.keyboardType == TextInputType.emailAddress ||
        widget.keyboardType == TextInputType.visiblePassword ||
        widget.keyboardType == TextInputType.url) {
      return TextCapitalization.none;
    }
    return TextCapitalization.sentences;
  }

  @override
  Widget build(BuildContext context) {
    final bool isObscureMode = widget.isPassword || widget.obscureText;

    // 📱 Escalado responsivo según ancho de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 400
        ? 1.0
        : screenWidth < 600
            ? 1.1
            : 1.2; // 🔹 ligeramente más grande que antes

    return TextFormField(
      focusNode: widget.focusNode,
      autofocus: false,
      controller: widget.controller,
      obscureText: isObscureMode && _isObscured,
      keyboardType: widget.keyboardType,
      textCapitalization: _getTextCapitalization(),
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      minLines: isObscureMode ? 1 : widget.minLines ?? 1,
      maxLines: isObscureMode ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      style: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w500,
        color: AppColors.textColor(context),
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: _hasFocus ? Colors.grey[700] : Colors.grey[600],
          fontWeight: FontWeight.w600,
          fontSize: 17 * scale,
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16 * scale),
        prefixIcon: Icon(
          widget.icon,
          color: widget.iconColor ?? AppColors.primaryColor(context),
          size: 22 * scale,
        ),
        suffixIcon: widget.suffixIcon ??
            (isObscureMode
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color:
                          widget.iconColor ?? AppColors.primaryColor(context),
                      size: 22 * scale,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Colors.transparent, width: 0.6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14 * scale),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 0.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14 * scale),
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? AppColors.primaryColor(context),
            width: 1.8,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(180),
        contentPadding: EdgeInsets.symmetric(
          vertical: 16 * scale,
          horizontal: 16 * scale,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}
