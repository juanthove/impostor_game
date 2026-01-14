import '../models/jugador.dart';

class GameState {
  // Singleton
  static final GameState instance = GameState._internal();
  GameState._internal();

  // ===== CONFIGURACIÓN DE LA PARTIDA =====
  bool usarTodas = true;
  List<int> categoriasSeleccionadas = [];
  int tiempoLimite = 0; // en minutos
  int cantidadImpostores = 1;
  bool usarPistas = false;
  bool votoImpostoresIndividual = true;

  // ===== ESTADO DEL JUEGO =====
  List<Jugador> jugadoresBase = [];
  List<Jugador> jugadores = [];
  String palabraReal = '';

  // ===== ESTADO DEL TIEMPO =====
  int tiempoRestante = 0; // en segundos
  bool tiempoPausado = false;
  bool tiempoTerminado = false;

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

    // Inicializar tiempo
    tiempoRestante = tiempoLimite * 60;
    tiempoPausado = false;
    tiempoTerminado = false;
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

  // ===== MANEJO DEL TIEMPO =====
  void pausarTiempo() {
    tiempoPausado = true;
  }

  void reanudarTiempo() {
    tiempoPausado = false;
  }

  void descontarSegundo() {
    if (tiempoPausado || tiempoTerminado) return;

    if (tiempoRestante > 0) {
      tiempoRestante--;
    }

    if (tiempoRestante <= 0) {
      tiempoRestante = 0;
      tiempoTerminado = true;
    }
  }

  // ===== REINICIAR RONDA (MISMA CONFIG) =====
  void resetParaNuevaRonda() {
    palabraReal = '';

    for (final j in jugadores) {
      j.eliminado = false;
      j.esImpostor = false;
    }

    // Reiniciar tiempo
    tiempoRestante = tiempoLimite * 60;
    tiempoPausado = false;
    tiempoTerminado = false;
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

    // Reset tiempo
    tiempoRestante = 0;
    tiempoPausado = false;
    tiempoTerminado = false;
  }

  void crearJugadoresParaRonda() {
    jugadores = jugadoresBase.map((j) => j.clone()).toList();
  }

}
