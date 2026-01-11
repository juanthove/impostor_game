class Palabra {
  int? id;
  String texto;
  int categoriaId;

  Palabra({
    this.id,
    required this.texto,
    required this.categoriaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'texto': texto,
      'categoria_id': categoriaId,
    };
  }

  factory Palabra.fromMap(Map<String, dynamic> map) {
    return Palabra(
      id: map['id'],
      texto: map['texto'],
      categoriaId: map['categoria_id'],
    );
  }
}

