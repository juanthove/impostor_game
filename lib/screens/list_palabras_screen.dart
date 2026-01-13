import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/palabra.dart';
import '../models/categoria.dart';
import '../utils/system_ui_helper.dart'; //Ocultar barra de navegación
import '../constants/ui_constants.dart'; //Para obtener el estilo del juego
import '../models/pista.dart';
import 'edit_palabra_sheet.dart';

class ListPalabrasScreen extends StatefulWidget {
  const ListPalabrasScreen({super.key});

  @override
  State<ListPalabrasScreen> createState() => _ListPalabrasScreenState();
  
}

class _ListPalabrasScreenState extends State<ListPalabrasScreen> {
  
  final DatabaseHelper db = DatabaseHelper.instance;
  final Map<int, List<Pista>> _pistasCache = {};

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
          style: kTitleAppBar,
        ),
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
            children: [
              // ===== Dropdown categorías =====
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
                  hintText: 'Categoría',
                  filled: true,
                  fillColor: kGrayField,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.grey.shade900,
              ),
              const SizedBox(height: 16),

              // ===== Lista de palabras =====
              Expanded(
                child: _cargando
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
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
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                                    collapsedIconColor: Colors.white,
                                    iconColor: Colors.white,
                                    textColor: Colors.white,
                                    collapsedTextColor: Colors.white,

                                    title: Text(
                                      palabra.texto,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),

                                    // ===== Subtitle con preview =====
                                    subtitle: const Text(
                                      'Tocá para ver pistas',
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),

                                    // ===== Botones editar / borrar =====
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // ✏️ Editar palabra
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.white),
                                          onPressed: () async {
                                            await showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true, // 🔥 obligatorio
                                              backgroundColor: Colors.transparent,
                                              builder: (context) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                                  ),
                                                  child: EditPalabraSheet(
                                                    palabra: palabra,
                                                  ),
                                                );
                                              },
                                            );

                                            _filtrarPalabras(); // refresca al cerrar el modal
                                          },
                                        ),

                                        // ❌ Borrar palabra
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
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
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, true),
                                                    child: const Text(
                                                      'Eliminar',
                                                      style: TextStyle(color: Colors.red),
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
                                      ],
                                    ),

                                    // ===== Pistas =====
                                    children: [
                                      Builder(
                                        builder: (_) {
                                          final palabraId = palabra.id!;

                                          if (_pistasCache.containsKey(palabraId)) {
                                            return _buildPistas(
                                              _pistasCache[palabraId]!,
                                            );
                                          }

                                          return FutureBuilder<List<Pista>>(
                                            future: db.getPistasPorPalabra(palabraId),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return const Padding(
                                                  padding: EdgeInsets.all(12),
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }

                                              final pistas = snapshot.data!;
                                              _pistasCache[palabraId] = pistas;

                                              return _buildPistas(pistas);
                                            },
                                          );
                                        },
                                      ),
                                    ],
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


  Widget _buildPistas(List<Pista> pistas) {
    if (pistas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'Sin pistas',
          style: TextStyle(
            color: Colors.white54,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }

    return Column(
      children: pistas.map((pista) {
        return ListTile(
          dense: true,
          title: Text(
            '• ${pista.texto}',
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Poppins',
            ),
          ),
        );
      }).toList(),
    );
  }

}

