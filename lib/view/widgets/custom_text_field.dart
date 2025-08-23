import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focus) {
        setState(() {
          _hasFocus = focus;
        });
      },
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword && _isObscured,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        style: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w500,
          color: AppColors.textColor,
        ),
        decoration: InputDecoration(
          // Label que siempre está presente pero se anima hacia arriba
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: _hasFocus ? Colors.grey[700] : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
          // Hint que se muestra cuando el campo está vacío
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            widget.icon, 
            color: AppColors.primaryColor, 
            size: 22,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscured 
                        ? Icons.visibility_off 
                        : Icons.visibility,
                    color: AppColors.primaryColor,
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
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 0.6,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 0.4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors.primaryColor,
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
      ),
    );
  }
}