import '../models/jugador.dart';

class GameState {
  // Singleton
  static final GameState instance = GameState._internal();
  GameState._internal();

  // ===== CONFIGURACIÓN DE LA PARTIDA =====
  bool usarTodas = true;
  List<int> categoriasSeleccionadas = [];
  int tiempoLimite = 0;
  int cantidadImpostores = 1;
  bool usarPistas = false;

  // ===== ESTADO DEL JUEGO =====
  List<Jugador> jugadores = [];
  String palabraReal = '';

  // ===== INICIALIZAR JUEGO =====
  void inicializarJuego({
    required List<Jugador> jugadores,
    required String palabraReal,
    required bool usarPistas,
    required int tiempoLimite,
    required List<int> categoriasSeleccionadas,
  }) {
    this.jugadores = jugadores;
    this.palabraReal = palabraReal;
    this.usarPistas = usarPistas;
    this.tiempoLimite = tiempoLimite;
    this.categoriasSeleccionadas = categoriasSeleccionadas;
  }

  // ===== HELPERS =====
  List<Jugador> get impostores =>
      jugadores.where((j) => j.esImpostor).toList();

  List<Jugador> get impostoresVivos =>
      jugadores.where((j) => j.esImpostor && !j.eliminado).toList();

  List<Jugador> get normalesVivos =>
      jugadores.where((j) => !j.esImpostor && !j.eliminado).toList();

  bool get ganoLaGenteNormal => impostoresVivos.isEmpty;

  bool get ganaronLosImpostores =>
      impostoresVivos.length >= normalesVivos.length;

  // ===== ACCIONES =====
  void eliminarJugador(Jugador jugador) {
    jugador.eliminado = true;
  }

  // ===== REINICIAR RONDA (MISMA CONFIG) =====
  void resetParaNuevaRonda() {
    palabraReal = '';

    for (final j in jugadores) {
      j.eliminado = false;
      j.esImpostor = false;
    }
  }

  // ===== RESET TOTAL (VOLVER AL INICIO) =====
  void resetTotal() {
    jugadores.clear();
    categoriasSeleccionadas.clear();
    palabraReal = '';
    tiempoLimite = 0;
    cantidadImpostores = 1;
    usarTodas = true;
    usarPistas = false;
  }
}
