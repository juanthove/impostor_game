import 'package:flutter/material.dart';

// Colores
const Color kGrayField = Color.fromARGB(255, 32, 29, 38); // gris oscuro de los campos/tarjetas
const Color kGrayLight = Color(0xFF616161); // gris claro secundario
const Color kBackgroundBase = Color.fromARGB(255, 235, 70, 120); //Color de fondo base

// Degradado de fondo
const LinearGradient kBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color.fromARGB(255, 236, 104, 181), // rosado arriba
    Color.fromARGB(255, 233, 35, 35), // rojo claro abajorojo abajo
  ],
);

// TextStyles
const TextStyle kTitleAppBar = TextStyle(
  color: Colors.white,
  fontSize: 28,
  fontWeight: FontWeight.bold,
);

const TextStyle kCardTitle = TextStyle(
  color: Colors.white,
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

const TextStyle kCardDescription = TextStyle(
  color: Colors.white,
  fontSize: 16,
);

const TextStyle kBlackButtonText = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w800,
  color: Colors.white,
  fontFamily: 'Poppins',
);

final ButtonStyle kBlackButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: kGrayField,        // fondo negro
  foregroundColor: Colors.white,        // color por defecto del texto
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(32),
  ),
);


const TextStyle kWhiteButtonText  = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

final ButtonStyle kWhiteButtonStyle  = ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  disabledBackgroundColor: Colors.white54,
  disabledForegroundColor: Colors.black38,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(32),
  ),
);
