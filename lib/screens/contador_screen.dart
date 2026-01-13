import 'dart:async';
import 'package:flutter/material.dart';
import 'votar_screen.dart';
import '../state/game_state.dart';
import '../utils/system_ui_helper.dart'; // Ocultar barras del sistema
import '../constants/ui_constants.dart'; //Constantes de diseño

class ContadorScreen extends StatefulWidget {
  const ContadorScreen({super.key});

  @override
  State<ContadorScreen> createState() => _ContadorScreenState();
}

class _ContadorScreenState extends State<ContadorScreen>
    with WidgetsBindingObserver {

  Timer? _timer;
  bool _enVotacion = false;

  final game = GameState.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemUIHelper.hideSystemBars();

    _iniciarTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemUIHelper.hideSystemBars();
    }
  }

 void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (game.tiempoPausado) return;

      setState(() {
        if (game.tiempoRestante > 0) {
          game.tiempoRestante--;
        } else {
          // ⏱️ Tiempo terminado → ir directo a votar
          game.tiempoTerminado = true;
          _timer?.cancel();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const VotarScreen(),
            ),
          );
        }
      });
    });
  }

  void _pausar() {
    setState(() {
      game.pausarTiempo();
    });
  }

  void _reanudar() {
    setState(() {
      game.reanudarTiempo();
    });
    _iniciarTimer();
  }

  Future<void> _irAVotar() async {
    if (_enVotacion) return;

    setState(() {
      _enVotacion = true;
      game.pausarTiempo();
    });

    _timer?.cancel();

    final bool? votoRealizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VotarScreen(),
      ),
    );

    if (!mounted) return;

    _enVotacion = false;

    // ⏱️ Solo volver a correr el tiempo si aún queda
    if (votoRealizado == true && !game.tiempoTerminado) {
      setState(() {
        game.reanudarTiempo();
        _iniciarTimer();
      });
    }
  }

  String _formatearTiempo() {
    final minutos = (game.tiempoRestante ~/ 60).toString().padLeft(2, '0');
    final segundos = (game.tiempoRestante % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemUIHelper.hideSystemBars();
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo gris
          Container(color: kGrayField),

          // Barra roja de tiempo (sube desde abajo)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height *
                (1 - game.tiempoRestante / (game.tiempoLimite * 60)),
            child: Container(color: Colors.red.shade700),
          ),

          // Contador centrado vertical y horizontalmente
          Center(
            child: Text(
              _formatearTiempo(),
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Botones flotando arriba del fondo, lado a lado
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 80,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!game.tiempoPausado)
                    SizedBox(
                      height: 64,
                      width: 300, // ancho fijo para que sea similar a Reanudar/Votar
                      child: ElevatedButton(
                        onPressed: _pausar,
                        style: kWhiteButtonStyle,
                        child: const Text('Pausar', style: kWhiteButtonText),
                      ),
                    ),
                  if (game.tiempoPausado) ...[
                    SizedBox(
                      height: 64,
                      width: 140, //Mismo ancho que Votar
                      child: ElevatedButton(
                        onPressed: _reanudar,
                        style: kWhiteButtonStyle,
                        child: const Text('Reanudar', style: kWhiteButtonText),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 64,
                      width: 140, //Mismo ancho que Reanudar
                      child: ElevatedButton(
                        onPressed: _irAVotar,
                        style: kWhiteButtonStyle,
                        child: const Text('Votar', style: kWhiteButtonText),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}