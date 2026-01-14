import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

/// Botón negro principal reusable
/// [texto] → texto que se muestra en el botón
/// [screen] → pantalla a la que se navega al presionar
class PrimaryBlackButton extends StatelessWidget {
  final String texto;
  final Widget screen;

  const PrimaryBlackButton({
    super.key,
    required this.texto,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
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