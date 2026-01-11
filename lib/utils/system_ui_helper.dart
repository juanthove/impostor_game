import 'package:flutter/services.dart';

class SystemUIHelper {
  // Oculta barra superior y barra inferior
  // Reaparecen con gesto y se vuelven a ocultar solas
  static void hideSystemBars() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  // Restaura el comportamiento normal del sistema
  static void restore() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }
}
