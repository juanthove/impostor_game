import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../db/database_helper.dart';
import '../models/palabra.dart';
import '../state/game_state.dart';
import 'contador_screen.dart';
import '../utils/system_ui_helper.dart';
import '../constants/ui_constants.dart';

class JuegoScreen extends StatefulWidget {
  const JuegoScreen({super.key});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> with SingleTickerProviderStateMixin {
  final DatabaseHelper db = DatabaseHelper.instance;
  final game = GameState.instance;

  List<String> palabrasAsignadas = [];
  List<String> pistasAsignadas = [];

  int jugadorActual = 0;
  bool palabraRevelada = false;
  bool esperaConfirmacion = false;
  bool _cargando = true;

  double _dragOffset = 0;
  static const double _cardHeight = 220; //Cuanto sube el bloque
  static const double _infoHeight = 180;
  late double _maxOffset;

  static const double _revealThreshold = 0.9; // 90% del recorrido

  final List<Color> coloresDisponibles = [
    const Color.fromARGB(255, 81, 171, 40),
    const Color.fromARGB(255, 238, 149, 28),
    const Color.fromARGB(255, 199, 62, 15),
    const Color.fromARGB(255, 85, 143, 224),
    const Color.fromARGB(255, 156, 97, 190),
    const Color.fromARGB(255, 46, 155, 163),
    const Color.fromARGB(255, 200, 185, 70),
    const Color.fromARGB(255, 204, 142, 122), 
  ];

  // Animación
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();
    SystemUIHelper.hideSystemBars();
    _inicializarJuego();

    // Configurar animación de subir y bajar
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), //Velocidad de subida del bloque negro
    );

    _animOffset = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.05), // mueve un poco hacia arriba
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));

    _animController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _inicializarJuego() async {
    final categorias = await db.getCategorias();

    final categoriasSeleccionadas = game.usarTodas
        ? categorias
        : categorias
            .where((c) => game.categoriasSeleccionadas.contains(c.id))
            .toList();

    List<Palabra> palabrasPosibles = [];
    for (final c in categoriasSeleccionadas) {
      palabrasPosibles.addAll(await db.getPalabras(categoriaId: c.id));
    }

    palabrasPosibles.shuffle();
    final palabraReal = palabrasPosibles.first;

    final pistas = await db.getPistasPorPalabra(palabraReal.id!);
    String pistaImpostor = '';

    if (game.usarPistas && pistas.isNotEmpty) {
      pistaImpostor = pistas[Random().nextInt(pistas.length)].texto;
    }

    final cantidad = game.jugadores.length;
    palabrasAsignadas = List.filled(cantidad, palabraReal.texto);
    pistasAsignadas = List.filled(cantidad, '');

    final indices = List.generate(cantidad, (i) => i)..shuffle();
    final impostores = indices.take(game.cantidadImpostores);

    for (final i in impostores) {
      palabrasAsignadas[i] = 'Impostor';
      pistasAsignadas[i] = pistaImpostor;
      game.jugadores[i].esImpostor = true;
    }

    _asignarColores();
    game.palabraReal = palabraReal.texto;

    setState(() => _cargando = false);
  }

  void _asignarColores() {
    final colores = List<Color>.from(coloresDisponibles)..shuffle();
    for (int i = 0; i < game.jugadores.length; i++) {
      game.jugadores[i].color = colores[i % colores.length];
    }
  }

  void _siguienteJugador() {
    if (jugadorActual < game.jugadores.length - 1) {
      setState(() {
        jugadorActual++;
        palabraRevelada = false;
        esperaConfirmacion = false;
        _dragOffset = 0;
        _animController.repeat(reverse: true); // reinicia animación
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ContadorScreen()),
      );
    }
  }

  void _revelarPalabra() {
    setState(() {
      palabraRevelada = true;
    });
  }

  @override
Widget build(BuildContext context) {
  if (_cargando ||
      game.jugadores.isEmpty ||
      palabrasAsignadas.isEmpty ||
      pistasAsignadas.isEmpty) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  _maxOffset = _cardHeight;
  final screenHeight = MediaQuery.of(context).size.height;

  final jugador = game.jugadores[jugadorActual];
  final palabra = palabrasAsignadas[jugadorActual];
  final pista = pistasAsignadas[jugadorActual];

  return Scaffold(
    body: GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset -= details.delta.dy;
          _dragOffset = _dragOffset.clamp(0, _maxOffset);
        });

        // 👇 Revelar apenas llega al umbral (una sola vez)
        if (!palabraRevelada &&
            _dragOffset >= _maxOffset * _revealThreshold) {
          _revelarPalabra();
        }
      },
      onVerticalDragEnd: (_) {
        // Animamos siempre hacia abajo
        setState(() => _dragOffset = 0);

        // 👇 SOLO habilitamos el botón si:
        // - la palabra ya fue revelada
        if (palabraRevelada) {
          _animController.stop(); // Detenemos animación cuando se revela
          setState(() {
            esperaConfirmacion = true;
          });
        }
      },
      child: Stack(
        children: [
          // Fondo con nombre del jugador
          Container(
            color: jugador.color,
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.only(top: screenHeight * 0.1),
            child: Text(
              jugador.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Bloque que sube
          AnimatedPositioned(
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: -_cardHeight + _dragOffset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Texto inicial + flecha animados
                if (!esperaConfirmacion)
                  SlideTransition(
                    position: _animOffset,
                    child: Transform.translate(
                      offset: const Offset(0, -30), // +30 mueve hacia abajo, -30 hacia arriba
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Deslizá hacia arriba\npara ver la palabra secreta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Icon(Icons.keyboard_arrow_up, size: 48),
                        ],
                      ),
                    ),
                  ),


                // 🔹 Texto de pasar el teléfono + botón cuando se reveló
                if (esperaConfirmacion)
                  TweenAnimationBuilder<Offset>(
                    tween: Tween(begin: const Offset(0, 0.05), end: Offset.zero),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    builder: (context, offset, child) {
                      return FractionalTranslation(
                        translation: offset,
                        child: child,
                      );
                    },
                    child: SizedBox(
                      height: _infoHeight + 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            jugadorActual < game.jugadores.length - 1
                                ? 'Pasá el teléfono a ${game.jugadores[jugadorActual + 1].nombre}'
                                : 'Todo listo para empezar',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: FadeTransition(opacity: animation, child: child),
                              );
                            },
                            child: esperaConfirmacion
                                ? FractionallySizedBox(
                                    widthFactor: 5 / 9,
                                    child: SizedBox(
                                      height: 62,
                                      child: ElevatedButton(
                                        onPressed: _siguienteJugador,
                                        style: kBlackButtonStyle,
                                        child: Text(
                                          jugadorActual < game.jugadores.length - 1
                                              ? 'Continuar'
                                              : 'Iniciar partida',
                                          style: kBlackButtonText,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(height: 62),
                          ),
                          const SizedBox(height: 8),
                          const Icon(Icons.keyboard_arrow_up, size: 48),
                        ],
                      ),
                    ),
                  ),

                // Tarjeta negra
                Container(
                  height: _cardHeight,
                  width: double.infinity,
                  color: Colors.black,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            palabra == 'Impostor'
                                ? 'assets/icons/impostor.svg'
                                : 'assets/icons/personas.svg',
                            width: 64,
                            height: 64,
                            colorFilter: ColorFilter.mode(
                              palabra == 'Impostor' ? Colors.red : Colors.green,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            palabra == 'Impostor' ? 'IMPOSTOR' : palabra,
                            style: TextStyle(
                              fontSize: 36,
                              color: palabra == 'Impostor' ? Colors.red : Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (game.usarPistas && pista.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Pista: $pista',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}





}

