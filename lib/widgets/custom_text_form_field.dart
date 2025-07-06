import 'package:flutter/material.dart';

import '../themes/colors.dart';

class CustomTextFormField extends StatelessWidget {


  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.label,
    this.isPassword = false,
    this.prefixIcon,
    this.controller,
    this.validator,
    this.onChanged,
    this.borderColor = const Color(0xffe4e4e4),
    this.fillColor = Colors.white,
    this.isTextArea = false
  });

  final String hintText;
  final bool isPassword;
  final String? label;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Color borderColor;
  final Color fillColor;
  final bool isTextArea;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label != null ? Text(
          label!,
          style: TextStyle(
            fontSize: 16
          ),
        ) : SizedBox.shrink(),
        label != null ? SizedBox(height: 10) : SizedBox.shrink(),
        TextFormField(
          maxLines: isTextArea ? 5 : 1,
          controller: controller,
          obscureText: isPassword,
          validator: validator ?? (value) => null,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
              prefixIcon,
              color: primaryColor,
              size: 20,
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 13.5,
            ),
          ),
        )
      ],
    );
  }
}