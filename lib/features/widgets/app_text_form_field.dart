import 'package:dhanra/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final TextStyle? labelStyle;
  final IconData? prefixIcon;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final int? maxLines;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final double verticalPadding;
  final double horizontalPadding;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.labelStyle,
    this.prefixIcon,
    this.prefixText,
    this.prefixStyle,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.style,
    this.maxLines = 1,
    this.validator,
    this.autofocus = false,
    this.verticalPadding = 0.0,
    this.horizontalPadding = 0.0,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: TextFormField(
        controller: controller,
        autofocus: autofocus,
        textAlign: textAlign,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        style: style ??
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: Colors.transparent,
          labelStyle: labelStyle ??
              const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.white54)
              : null,
          prefixText: prefixText,
          prefixStyle: prefixStyle,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withAlpha(15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withAlpha(15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        validator: validator,
      ),
    );
  }
}
