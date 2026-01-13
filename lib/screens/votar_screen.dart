// Pantalla de votación
import 'package:flutter/material.dart';
import '../models/jugador.dart';
import '../state/game_state.dart';
import 'final_screen.dart';
import '../utils/system_ui_helper.dart'; //Ocultar barra de navegación
import '../constants/ui_constants.dart'; //Constantes de diseño

class VotarScreen extends StatefulWidget {
  const VotarScreen({super.key});

  @override
  State<VotarScreen> createState() => _VotarScreenState();
}

class _VotarScreenState extends State<VotarScreen> {
  final GameState game = GameState.instance;

  Jugador? jugadorSeleccionado;
  bool votoEnviado = false;
  bool finJuego = false;
  bool eraImpostor = false;

  //Variables para modo todos juntos
  final List<Jugador> jugadoresSeleccionados = [];
  int get maxVotos => game.cantidadImpostores;
  bool get esVotoIndividual =>
      game.cantidadImpostores == 1 || game.votoImpostoresIndividual;
  bool get seleccionMultiple =>
      game.cantidadImpostores > 1 && !esVotoIndividual;



  String mensajeResultado = '';
  Color fondoResultado = Colors.black;

  @override
  void initState() {
    super.initState();
    SystemUIHelper.hideSystemBars();
  }

  void enviarVoto() {
    if (!esVotoIndividual) {
      // 🔹 MODO TODOS JUNTOS
      final impostores = game.jugadores.where((j) => j.esImpostor).toList();

      final impostoresVotados = jugadoresSeleccionados
          .where((j) => j.esImpostor)
          .length;

      final gananNormales = impostoresVotados == impostores.length;
      final gananImpostores = !gananNormales;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FinalScreen(
            ganoImpostores: gananImpostores,
          ),
        ),
      );
    } else {
      // 🔹 MODO INDIVIDUAL (igual que antes)
      if (jugadorSeleccionado == null) return;

      eraImpostor = jugadorSeleccionado!.esImpostor;
      game.eliminarJugador(jugadorSeleccionado!);

      if (game.ganoLaGenteNormal || game.ganaronLosImpostores) {
        finJuego = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FinalScreen(
              ganoImpostores: game.ganaronLosImpostores,
            ),
          ),
        );
      } else {
        setState(() {
          votoEnviado = true;
          mensajeResultado = eraImpostor
              ? '${jugadorSeleccionado!.nombre} ERA impostor'
              : '${jugadorSeleccionado!.nombre} no era impostor';
        });
      }
    }
  }

  void reiniciarVotacion() {
    setState(() {
      votoEnviado = false;
      jugadorSeleccionado = null;
      mensajeResultado = '';
      jugadoresSeleccionados.clear();
      // NO tocar finJuego
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrayField,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // quita la flecha de retroceso
        centerTitle: true,                  // asegura que el título esté centrado
        title: const Text(
          '¿Quién es el impostor?',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800, // ExtraBold
            fontSize: 28,                // tamaño más grande
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '¡Envíen su voto cuando estén listos!',
                textAlign: TextAlign.center, // centrado
                style: TextStyle(
                  color: Colors.white, // blanco
                  fontSize: 18,        // un poquito más grande si quieres
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// GRID DE JUGADORES
            Expanded(
              child: GridView.builder(
                itemCount: game.jugadores.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final jugador = game.jugadores[index];
                  final bool seleccionado = seleccionMultiple
                      ? jugadoresSeleccionados.contains(jugador)
                      : jugador == jugadorSeleccionado;
                      
                  return GestureDetector(
                    onTap: jugador.eliminado || votoEnviado
                        ? null
                        : () {
                            setState(() {
                              if (seleccionMultiple) {
                                // 🔹 MULTIPLE (todos juntos)
                                if (jugadoresSeleccionados.contains(jugador)) {
                                  jugadoresSeleccionados.remove(jugador);
                                } else {
                                  if (jugadoresSeleccionados.length < game.cantidadImpostores) {
                                    jugadoresSeleccionados.add(jugador);
                                  }
                                }
                              } else {
                                // 🔹 INDIVIDUAL (siempre reemplaza)
                                jugadorSeleccionado = jugador;
                                jugadoresSeleccionados.clear(); // por seguridad
                              }
                            });
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? Color.alphaBlend(
                                Colors.black.withValues(alpha: 0.25),
                                (jugador.color ?? Colors.grey),
                              )
                            : (jugador.color ?? Colors.grey).withValues(
                                alpha: jugador.eliminado ? 0.35 : 1,
                              ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: seleccionado
                              ? Colors.white
                              : Colors.transparent,
                          width: 4,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Nombre abajo centrado
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Text(
                              jugador.nombre,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: seleccionado
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),

                          // Ícono de eliminado
                          if (jugador.eliminado)
                            const Positioned(
                              top: 12,
                              right: 12,
                              child: Icon(
                                Icons.block,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// BOTÓN ENVIAR VOTO
            if (!votoEnviado && ((!seleccionMultiple && jugadorSeleccionado != null) || (seleccionMultiple &&jugadoresSeleccionados.length == game.cantidadImpostores)))
              SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: enviarVoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      esVotoIndividual ? 'ENVIAR VOTO' : 'ENVIAR VOTOS',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            /// RESULTADO
            if (votoEnviado) ...[
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    eraImpostor
                        ? Icons.check_rounded   // ✔ impostor
                        : Icons.close_rounded,  // ❌ no impostor
                    color: eraImpostor
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      mensajeResultado,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Boton Continuar juego
              if (!finJuego)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (game.tiempoTerminado) {
                        // ⏱️ El tiempo ya terminó → votar de nuevo
                        reiniciarVotacion();
                      } else {
                        // ⏳ Todavía hay tiempo → volver al contador
                        Navigator.pop(context, true);
                      }
                    },
                    style: kWhiteButtonStyle,
                    child: const Text(
                      'Continuar juego',
                      style: kWhiteButtonText,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
