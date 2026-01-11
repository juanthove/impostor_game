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

class _ContadorScreenState extends State<ContadorScreen> with WidgetsBindingObserver{
  late int _segundosRestantes;
  late int _tiempoTotal;

  Timer? _timer;
  bool _pausado = false;
  bool _enVotacion = false;

  final game = GameState.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemUIHelper.hideSystemBars();

    _tiempoTotal = game.tiempoLimite * 60;
    _segundosRestantes = _tiempoTotal;

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
      if (!_pausado) {
        setState(() {
          if (_segundosRestantes > 0) {
            _segundosRestantes--;
          } else {
            _timer?.cancel();
            _irAVotar();
          }
        });
      }
    });
  }

  void _pausar() {
    setState(() {
      _pausado = true;
    });
  }

  void _reanudar() {
    setState(() {
      _pausado = false;
    });
    _iniciarTimer();
  }


  Future<void> _irAVotar() async {
    if (_enVotacion) return;

    setState(() {
      _enVotacion = true;
      _pausado = true;
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

    if (votoRealizado == true && _segundosRestantes > 0) {
      setState(() {
        _pausado = false;
        _iniciarTimer();
      });
    }
  }

  String _formatearTiempo() {
    final minutos = (_segundosRestantes ~/ 60).toString().padLeft(2, '0');
    final segundos = (_segundosRestantes % 60).toString().padLeft(2, '0');
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
                (1 - _segundosRestantes / (game.tiempoLimite * 60)),
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
                  if (!_pausado)
                    SizedBox(
                      height: 64,
                      width: 300, // ancho fijo para que sea similar a Reanudar/Votar
                      child: ElevatedButton(
                        onPressed: _pausar,
                        style: kWhiteButtonStyle,
                        child: const Text('Pausar', style: kWhiteButtonText),
                      ),
                    ),
                  if (_pausado) ...[
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
