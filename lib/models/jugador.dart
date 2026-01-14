import 'package:flutter/material.dart';

class Jugador {
  String nombre;
  bool esImpostor;
  bool eliminado;
  Color? color;
  String? poseAsset;

  Jugador({
    required this.nombre,
    required this.esImpostor,
    this.color,
    this.poseAsset,
    this.eliminado = false,
  });
  
  Jugador clone() {
    return Jugador(
      nombre: nombre,
      esImpostor: esImpostor,
      eliminado: eliminado,
      color: color,
      poseAsset: poseAsset,
    );
  }
}
