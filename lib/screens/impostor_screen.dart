// Pantalla para seleccionar las opciones del impostor
import 'package:flutter/material.dart';
import '../state/game_state.dart';
import 'juego_screen.dart';
import '../constants/ui_constants.dart'; //Constantes de diseño
import '../utils/system_ui_helper.dart'; //Ocultar barra de navegación

class ImpostorScreen extends StatefulWidget {
  const ImpostorScreen({super.key});

  @override
  State<ImpostorScreen> createState() => _ImpostorScreenState();
}

class _ImpostorScreenState extends State<ImpostorScreen> {
  final game = GameState.instance;

  int _cantidadImpostores = 1;
  int _tiempoLimite = 2;
  bool _recibePista = false;

  @override
  void initState() {
    super.initState();

    SystemUIHelper.hideSystemBars();
    // Valores por defecto desde GameState (por si vuelve a esta pantalla)
    _cantidadImpostores = game.cantidadImpostores;
    _tiempoLimite = game.tiempoLimite == 0 ? 2 : game.tiempoLimite;
    _recibePista = game.usarPistas;
  }

  @override
  void dispose() {
    //SystemUIHelper.restore();
    super.dispose();
  }

  void _iniciarJuego() {
    // Guardar configuración en GameState
    game.cantidadImpostores = _cantidadImpostores;
    game.tiempoLimite = _tiempoLimite;
    game.usarPistas = _recibePista;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const JuegoScreen(),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? Colors.white24 : Colors.white12,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _toggleOption({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cantidadJugadores = game.jugadores.length;
    final maxImpostores = (cantidadJugadores - 1) ~/ 2;

    //Volver a ocultar las barras al ingresar desde revancha
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemUIHelper.hideSystemBars();
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Configuración del juego', style: kTitleAppBar),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //TARJETA: CANTIDAD DE IMPOSTORES
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: kGrayField,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Impostores', style: kCardTitle),
                    const SizedBox(height: 6),
                    Text(
                      '¿Cuántos jugadores serán impostores?\n',
                      style: kCardDescription,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _circleButton(
                          icon: Icons.remove,
                          enabled: _cantidadImpostores > 1,
                          onTap: () => setState(() => _cantidadImpostores--),
                        ),
                        const SizedBox(width: 32),
                        Text('$_cantidadImpostores', style: kCardTitle),
                        const SizedBox(width: 32),
                        _circleButton(
                          icon: Icons.add,
                          enabled: _cantidadImpostores < maxImpostores,
                          onTap: () => setState(() => _cantidadImpostores++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // TARJETA: PISTAS
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: kGrayField,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pistas para impostores', style: kCardTitle),
                    const SizedBox(height: 6),
                    const Text(
                      '¿Deberían los impostores recibir una pista sobre la palabra secreta?',
                      style: kCardDescription,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          _toggleOption(
                            text: 'Desactivado',
                            selected: !_recibePista,
                            onTap: () => setState(() => _recibePista = false),
                          ),
                          _toggleOption(
                            text: 'Activado',
                            selected: _recibePista,
                            onTap: () => setState(() => _recibePista = true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // TARJETA: TIEMPO LÍMITE
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: kGrayField,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Duración de la ronda', style: kCardTitle),
                    const SizedBox(height: 6),
                    const Text(
                      '¿Cuánto debe durar cada ronda de debate?',
                      style: kCardDescription,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _circleButton(
                          icon: Icons.remove,
                          enabled: _tiempoLimite > 1,
                          onTap: () => setState(() => _tiempoLimite--),
                        ),
                        const SizedBox(width: 32),
                        Text(
                          '${_tiempoLimite.toString().padLeft(2, '0')}:00',
                          style: kCardTitle,
                        ),
                        const SizedBox(width: 32),
                        _circleButton(
                          icon: Icons.add,
                          enabled: _tiempoLimite < 10,
                          onTap: () => setState(() => _tiempoLimite++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // BOTÓN INICIAR
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _iniciarJuego,
                  style: kWhiteButtonStyle,
                  child: Text(
                    'JUGAR  |  $_cantidadImpostores Impostor${_cantidadImpostores > 1 ? 'es' : ''}',
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


}
