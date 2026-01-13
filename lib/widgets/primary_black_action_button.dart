import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

class PrimaryBlackActionButton extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const PrimaryBlackActionButton({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: kBlackButtonStyle,
        child: Text(
          texto,
          style: kBlackButtonText.copyWith(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
