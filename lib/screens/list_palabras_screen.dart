import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/palabra.dart';
import '../models/categoria.dart';
import '../utils/system_ui_helper.dart'; //Ocultar barra de navegación
import '../constants/ui_constants.dart'; //Para obtener el estilo del juego

class ListPalabrasScreen extends StatefulWidget {
  const ListPalabrasScreen({super.key});

  @override
  State<ListPalabrasScreen> createState() => _ListPalabrasScreenState();
}

class _ListPalabrasScreenState extends State<ListPalabrasScreen> {
  final DatabaseHelper db = DatabaseHelper.instance;

  List<Categoria> _categorias = [];
  List<Palabra> _palabras = [];

  Categoria? _categoriaSeleccionada;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    SystemUIHelper.hideSystemBars();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);

    final categorias = await db.getCategorias();
    final palabras = await db.getPalabras();

    if (!mounted) return;

    setState(() {
      _categorias = categorias;
      _palabras = palabras;
      _categoriaSeleccionada = null;
      _cargando = false;
    });
  }


  Future<void> _filtrarPalabras() async {
    final palabras = await db.getPalabras(
      categoriaId: _categoriaSeleccionada?.id,
    );

    if (!mounted) return;

    setState(() {
      _palabras = palabras;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Listado de palabras',
          style: kTitleAppBar, // misma fuente y estilo que otras pantallas
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kBackgroundGradient, // mismo fondo que en otras páginas
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
          child: Column(
            children: [
              // Dropdown de categorías
              DropdownButtonFormField<Categoria?>(
                initialValue: _categoriaSeleccionada,
                items: [
                  const DropdownMenuItem<Categoria?>(
                    value: null,
                    child: Text('Todas'),
                  ),
                  ..._categorias.map(
                    (c) => DropdownMenuItem<Categoria?>(
                      value: c,
                      child: Text(c.nombre),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                  _filtrarPalabras();
                },
                iconEnabledColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Categoría',         // aparece dentro del campo
                  filled: true,
                  fillColor: kGrayField,         // fondo gris oscuro
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.grey.shade900,
              ),
              const SizedBox(height: 16),

              // Lista de palabras
              Expanded(
                child: _cargando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : _palabras.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay palabras',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _palabras.length,
                            itemBuilder: (context, index) {
                              final palabra = _palabras[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: kGrayField,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      palabra.texto,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirmar = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            backgroundColor: kGrayField,
                                            title: const Text(
                                              'Eliminar palabra',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            content: Text(
                                              '¿Eliminar "${palabra.texto}"?',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                                child: const Text(
                                                  'Cancelar',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, true),
                                                child: const Text(
                                                  'Eliminar',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmar == true) {
                                          await db.deletePalabra(palabra.id!);
                                          _filtrarPalabras();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

