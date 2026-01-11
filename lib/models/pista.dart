class Pista {
  final int? id;
  final int palabraId;
  final String texto;

  Pista({
    this.id,
    required this.palabraId,
    required this.texto,
  });

  factory Pista.fromMap(Map<String, dynamic> map) {
    return Pista(
      id: map['id'],
      palabraId: map['palabra_id'],
      texto: map['texto'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'palabra_id': palabraId,
      'texto': texto,
    };
  }
}
