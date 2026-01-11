import 'package:flutter/material.dart';
import '../state/game_state.dart';
import '../models/jugador.dart';
import 'home_screen.dart';
import '../constants/ui_constants.dart';

class FinalScreen extends StatelessWidget {
  final bool ganoImpostores;

  const FinalScreen({
    super.key,
    required this.ganoImpostores,
  });

  @override
  Widget build(BuildContext context) {
    final GameState game = GameState.instance;

    // Mensajes según quién gane
    final String titleText =
        ganoImpostores ? '¡Gana el impostor!' : '¡Ganan los jugadores!';
    final String subtitleText = ganoImpostores
        ? 'El impostor pasó desapercibido'
        : 'El impostor fue descubierto';

    // --- Cálculo de altura dinámica del bloque gris ---
    int filas = (game.impostores.length / 2).ceil();
    double alturaTarjeta = 180;
    double alturaMensaje = 64; // espacio para title + subtitle + padding
    double alturaExtraAbajo = 64; // espacio extra debajo de la última tarjeta
    double alturaTotal =
        alturaMensaje + filas * alturaTarjeta + (16 * (filas - 1)) + alturaExtraAbajo;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: null, // título movido dentro del body
      ),
      body: Container(
        color: ganoImpostores ? Colors.redAccent : Colors.green,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 32), // espacio superior para bajar todo

              // --- Parte superior que ocupa todo el espacio disponible ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Título "Resultados"
                      const Text(
                        'Resultados',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // BLOQUE GRIS UNIFICADO: mensaje + tarjetas
                      Container(
                        width: double.infinity,
                        height: alturaTotal,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: kGrayField,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Mensaje de quién ganó
                            Text(
                              titleText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitleText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Tarjetas de impostores
                            Expanded(
                              child: LayoutBuilder(builder: (context, constraints) {
                                final double cardWidth = (constraints.maxWidth - 16) / 2;
                                List<Widget> filasWidgets = [];

                                for (int i = 0; i < game.impostores.length; i += 2) {
                                  List<Widget> fila = [];
                                  fila.add(_buildJugadorCard(game.impostores[i], cardWidth));
                                  if (i + 1 < game.impostores.length) {
                                    fila.add(const SizedBox(width: 16));
                                    fila.add(_buildJugadorCard(game.impostores[i + 1], cardWidth));
                                  }
                                  filasWidgets.add(Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: fila,
                                  ));
                                  filasWidgets.add(const SizedBox(height: 16));
                                }

                                return SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: filasWidgets,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16), // separación antes de palabra secreta

                      // Palabra secreta
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: kGrayField,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Palabra secreta',
                              style: TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              game.palabraReal,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Botones siempre abajo ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: kWhiteButtonStyle,
                  onPressed: () {
                    game.resetParaNuevaRonda();
                    Navigator.popUntil(
                      context,
                      (route) => route.settings.name == 'impostor',
                    );
                  },
                  child: const Text('Jugar de nuevo', style: kWhiteButtonText),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: kWhiteButtonStyle,
                  onPressed: () {
                    game.resetTotal();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (_) => false,
                    );
                  },
                  child: const Text('Salir', style: kWhiteButtonText),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildJugadorCard(Jugador jugador, double width) {
    return Container(
      width: width,
      height: 180,
      decoration: BoxDecoration(
        color: kGrayField, // fondo gris oscuro detrás de la tarjeta
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Capa encima con color del jugador
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (jugador.color ?? Colors.grey).withOpacity(1),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Text(
              jugador.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
