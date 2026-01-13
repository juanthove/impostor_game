import 'package:flutter/material.dart';

class OpcionButton extends StatefulWidget {
  final String texto;
  final IconData icono;
  final VoidCallback onTap;

  const OpcionButton({
    super.key,
    required this.texto,
    required this.icono,
    required this.onTap,
  });

  @override
  State<OpcionButton> createState() => _OpcionButtonState();
}

class _OpcionButtonState extends State<OpcionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.texto,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Icon(
                widget.icono,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
