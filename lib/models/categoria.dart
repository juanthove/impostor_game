class Categoria {
  final int? id;
  final String nombre;
  final String descripcion;
  final String imagen; // ruta del asset

  Categoria({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
  });

  // Convertir de Map (de la DB) a objeto
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String,
      imagen: map['imagen'] as String,
    );
  }

  // Convertir de objeto a Map (si necesitas insertarlo)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen': imagen,
    };
  }
}
