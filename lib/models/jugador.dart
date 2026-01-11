import 'package:flutter/material.dart';

class Jugador {
  String nombre;
  bool esImpostor;
  bool eliminado;
  Color? color;

  Jugador({
    required this.nombre,
    required this.esImpostor,
    this.color,
    this.eliminado = false,
  });
}
