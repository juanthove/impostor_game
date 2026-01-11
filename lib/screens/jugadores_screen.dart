import 'package:flutter/material.dart';
import 'categorias_juego_screen.dart';
import '../state/game_state.dart';
import '../models/jugador.dart';
import '../constants/ui_constants.dart'; //Constantes de diseño
import '../utils/system_ui_helper.dart'; //Ocultar barra de navegación
import '../widgets/primary_black_text_field.dart';

class JugadoresScreen extends StatefulWidget {
  const JugadoresScreen({super.key});

  @override
  State<JugadoresScreen> createState() => _JugadoresScreenState();
}

class _JugadoresScreenState extends State<JugadoresScreen> {
  final List<TextEditingController> _controllers = [TextEditingController()];
  final List<FocusNode> _focusNodes = [FocusNode()];

  final double _botonSize = 50; // tamaño del + o X

  @override
  void initState() {
    super.initState();
    SystemUIHelper.hideSystemBars();
  }

  void _agregarJugador() {
    setState(() {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNodes.last.requestFocus();
    });
  }

  void _eliminarJugador(int index) {
    setState(() {
      _controllers[index].dispose();
      _focusNodes[index].dispose();
      _controllers.removeAt(index);
      _focusNodes.removeAt(index);
    });
  }

  void _irAJugar() {
    final nombres = _controllers
        .sublist(0, _controllers.length - 1)
        .map((c) => c.text.trim())
        .where((nombre) => nombre.isNotEmpty)
        .toList();

    if (nombres.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregá al menos 3 jugadores')),
      );
      return;
    }

    final game = GameState.instance;

    game.jugadores =
        nombres.map((n) => Jugador(nombre: n, esImpostor: false)).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CategoriasJuegoScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int jugadoresConNombre = _controllers
        .sublist(0, _controllers.length - 1)
        .map((c) => c.text.trim())
        .where((nombre) => nombre.isNotEmpty)
        .length;

    bool botonHabilitado = jugadoresConNombre >= 3;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Jugadores', style: kTitleAppBar),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kBackgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
          child: Column(
            children: [
              /// LISTA DE JUGADORES
              Expanded(
                child: ListView.builder(
                  itemCount: _controllers.length,
                  itemBuilder: (context, index) {
                    final esUltimo = index == _controllers.length - 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          /// CAMPO DE TEXTO
                          Expanded(
                            child: SizedBox(
                              height: _botonSize + 10,
                              child: PrimaryBlackTextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                hint: 'Nombre del jugador',
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 22, // 👈 CLAVE
                                  horizontal: 20,
                                ),
                                suffix: !esUltimo
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _eliminarJugador(index),
                                      )
                                    : null,
                              ),
                            ),
                          ),

                          /// BOTÓN +
                          if (esUltimo) const SizedBox(width: 8),
                          if (esUltimo)
                            Container(
                              width: _botonSize,
                              height: _botonSize,
                              decoration: const BoxDecoration(
                                color: kGrayField,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: _agregarJugador,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// BOTÓN CONTINUAR
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: botonHabilitado ? _irAJugar : null,
                  style: kWhiteButtonStyle,
                  child: Text(
                    'CONTINUAR | $jugadoresConNombre Jugadores',
                    style: kWhiteButtonText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
