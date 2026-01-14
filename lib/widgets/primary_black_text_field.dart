import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

class PrimaryBlackTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextCapitalization capitalization;
  final FocusNode? focusNode;
  final Widget? suffix;

  /// 👇 ESTE ES EL QUE FALTA
  final EdgeInsets? contentPadding;

  const PrimaryBlackTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.capitalization = TextCapitalization.words,
    this.focusNode,
    this.suffix,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textCapitalization: capitalization,
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white54,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: kGrayField,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),

        /// 👇 SI NO PASÁS NADA, USA EL DEFAULT
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),

        suffixIcon: suffix,
      ),
    );
  }
}
