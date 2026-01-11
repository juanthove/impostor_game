//Funciones para modificar la base de datos

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/categoria.dart';
import '../models/palabra.dart';
import '../models/pista.dart';

//Para leer json
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'impostor.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        descripcion TEXT,
        imagen TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE palabras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        texto TEXT NOT NULL,
        categoria_id INTEGER NOT NULL,
        UNIQUE(texto, categoria_id),
        FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pistas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        palabra_id INTEGER NOT NULL,
        texto TEXT NOT NULL,
        FOREIGN KEY (palabra_id) REFERENCES palabras(id) ON DELETE CASCADE
      )
    ''');

    await _insertarDatosIniciales(db);
  }

  //Cargar categorías desde JSON
  Future<List<Map<String, dynamic>>> cargarCategoriasDesdeJson() async {
    final String jsonString = await rootBundle.loadString('assets/categorias.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return List<Map<String, dynamic>>.from(jsonData);
  }


  //Cargar palabras desde JSON
  Future<List<Map<String, dynamic>>> cargarPalabrasDesdeJson() async {
    final String jsonString = await rootBundle.loadString('assets/palabras.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return List<Map<String, dynamic>>.from(jsonData);
  }

  //Inserta las categorias y llama a insertar palabras
  Future<void> _insertarDatosIniciales(Database db) async {
    final categorias = await cargarCategoriasDesdeJson();

    for (final item in categorias) {
      await db.insert(
        'categorias',
        {
          'nombre': item['nombre'],
          'descripcion': item['descripcion'],
          'imagen': item['imagen'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    final palabras = await cargarPalabrasDesdeJson();
    await insertarPalabrasDesdeLista(db, palabras);
  }




  //Funcion que recorre la lista de palabras y llama a insertar
  Future<void> insertarPalabrasDesdeLista(
    Database db,
    List<Map<String, dynamic>> palabras,
  ) async {
    // Obtener categorías existentes
    final categoriasDb = await db.query('categorias');

    // Map nombre -> id
    final Map<String, int> categoriaMap = {
      for (final c in categoriasDb)
        c['nombre'] as String: c['id'] as int,
    };

    for (final item in palabras) {
      final palabra = item['palabra'] as String;
      final nombreCategoria = item['categoria'] as String;
      final pistas = List<String>.from(item['pistas']);

      final categoriaId = categoriaMap[nombreCategoria];

      if (categoriaId == null) {
        // Si la categoría no existe, la salteamos
        continue;
      }

      await _insertarPalabraConPistas(
        db: db,
        palabra: palabra,
        categoriaId: categoriaId,
        pistas: pistas,
      );
    }
  }


  //Funcion para insertar datos
  Future<void> _insertarPalabraConPistas({
    required Database db,
    required String palabra,
    required int categoriaId,
    required List<String> pistas,
  }) async {
    // Insertar palabra
    final palabraId = await db.insert(
      'palabras',
      {
        'texto': palabra,
        'categoria_id': categoriaId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Si ya existía, no insertar pistas de nuevo
    if (palabraId == 0) return;

    // Insertar pistas
    for (final pista in pistas) {
      await db.insert(
        'pistas',
        {
          'texto': pista,
          'palabra_id': palabraId,
        },
      );
    }
  }


  //Funcion de insertar una categoria
  Future<int?> insertCategoriaSinDuplicar(Categoria categoria) async {
    final existe = await categoriaExiste(categoria.nombre);

    if (existe) return null;

    final db = await database;
    return await db.insert('categorias', categoria.toMap());
  }


  //Funcion de listar todas las categorias
  Future<List<Categoria>> getCategorias() async {
    final db = await database;

    // Esto trae todas las columnas: id, nombre, descripcion, imagen
    final List<Map<String, dynamic>> maps = await db.query('categorias');

    return List.generate(maps.length, (i) {
      return Categoria.fromMap(maps[i]);
    });
  }


  //Funcion para comprobar si existe una categoria
  Future<bool> categoriaExiste(String nombre) async {
    final db = await database;

    final result = await db.query(
      'categorias',
      where: 'nombre = ?',
      whereArgs: [nombre],
      limit: 1,
    );

    return result.isNotEmpty;
  }


  //Funcion para insertar una palabra
  Future<int?> insertPalabraSinDuplicar(Palabra palabra) async {
    final existe = await palabraExiste(
      palabra.texto,
      palabra.categoriaId,
    );

    if (existe) {
      return null; //Ya existe la palabra y la categoria
    }

    final db = await database;
    return await db.insert('palabras', palabra.toMap());
  }

  //Funcion para obtener las palabras
  Future<List<Palabra>> getPalabras({int? categoriaId}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = categoriaId == null
        ? await db.query('palabras')
        : await db.query(
            'palabras',
            where: 'categoria_id = ?',
            whereArgs: [categoriaId],
          );

    return List.generate(maps.length, (i) {
      return Palabra.fromMap(maps[i]);
    });
  }


  //Verificar que existe esa palabra en la base
  Future<bool> palabraExiste(String texto, int categoriaId) async {
    final db = await database;

    final result = await db.query(
      'palabras',
      where: 'texto = ? AND categoria_id = ?',
      whereArgs: [texto, categoriaId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  //Eliminar una palabra
  Future<void> deletePalabra(int id) async {
    final db = await database;

    await db.delete(
      'palabras',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //Funcion para insertar una pista
  Future<void> insertPista(Pista pista) async {
    final db = await database;
    await db.insert('pistas', pista.toMap());
  }

  //Funcion para obtener todas las pistar por palabra
  Future<List<Pista>> getPistasPorPalabra(int palabraId) async {
    final db = await database;

    final maps = await db.query(
      'pistas',
      where: 'palabra_id = ?',
      whereArgs: [palabraId],
    );

    return maps.map((e) => Pista.fromMap(e)).toList();
  }

  //Insertar la palabra y sus pistas
  Future<int?> insertarPalabraConPistas({
    required String texto,
    required int categoriaId,
    required List<String> pistas,
  }) async {
    //Crear objeto Palabra
    final palabra = Palabra(texto: texto, categoriaId: categoriaId);
    // Insertar palabra
    final palabraId = await insertPalabraSinDuplicar(palabra);

    if (palabraId == null) {
      //La palabra ya existía
      return null;
    }

    //Insertar cada pista asociada a la palabra recién creada
    for (final pistaTexto in pistas.where((p) => p.isNotEmpty)) {
      await insertPista(Pista(palabraId: palabraId, texto: pistaTexto));
    }

    return palabraId;
  }



}
