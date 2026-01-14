import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/categoria.dart';
import '../state/game_state.dart';
import 'impostor_screen.dart';
import '../constants/ui_constants.dart'; //Constantes de diseño
import '../utils/system_ui_helper.dart'; //Ocultar barra de navegación
import 'dart:io';


class CategoriasJuegoScreen extends StatefulWidget {
  const CategoriasJuegoScreen({super.key});

  @override
  State<CategoriasJuegoScreen> createState() => _CategoriasJuegoScreenState();
}

class _CategoriasJuegoScreenState extends State<CategoriasJuegoScreen> {
  final DatabaseHelper db = DatabaseHelper.instance;
  final game = GameState.instance;

  List<Categoria> _categorias = [];
  bool _todas = true;
  final Set<int> _categoriasSeleccionadas = {};

  bool _hayPalabras = false;
  bool _cargandoChequeo = false;


  @override
  void initState() {
    super.initState();
    SystemUIHelper.hideSystemBars();
    _cargarCategorias().then((_) => _validarPalabras());
  }

  Future<void> _cargarCategorias() async {
    final categorias = await db.getCategorias();
    setState(() {
      _categorias = categorias;
    });
  }

  void _toggleTodas(bool value) {
    setState(() {
      _todas = value;
      _categoriasSeleccionadas.clear();
    });

    _validarPalabras();
  }

  void _toggleCategoria(int id) {
    setState(() {
      _todas = false;
      if (_categoriasSeleccionadas.contains(id)) {
        _categoriasSeleccionadas.remove(id);
      } else {
        _categoriasSeleccionadas.add(id);
      }
    });

    _validarPalabras();
  }

  void _continuar() {
    game.usarTodas = _todas;
    game.categoriasSeleccionadas = _categoriasSeleccionadas.toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'impostor'),
        builder: (_) => const ImpostorScreen(),
      ),
    );
  }

  Future<void> _validarPalabras() async {
    setState(() {
      _cargandoChequeo = true;
    });

    bool existe;

    if (_todas) {
      existe = await db.existeAlgunaPalabra();
    } else {
      existe = await db.existePalabraEnCategorias(
        _categoriasSeleccionadas.toList(),
      );
    }

    setState(() {
      _hayPalabras = existe;
      _cargandoChequeo = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    bool botonHabilitado = !_cargandoChequeo && _hayPalabras && (_todas || _categoriasSeleccionadas.isNotEmpty);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Categorías', style: kTitleAppBar),
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
              // Checkbox "Todas"
              CheckboxListTile(
                title: const Text(
                  'Todas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                value: _todas,
                onChanged: (value) => _toggleTodas(value!),
                activeColor: Colors.white,
                checkColor: Colors.grey.shade800,
              ),
              const Divider(color: Colors.white54),
              // Lista de categorías scrollable
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = _categorias[index];
                    final seleccionado = _categoriasSeleccionadas.contains(categoria.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _toggleCategoria(categoria.id!),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: kGrayField, // siempre gris
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: seleccionado ? Colors.white : Colors.transparent, // borde blanco si seleccionado
                              width: 5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(categoria.nombre, style: kCardTitle),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          categoria.descripcion,
                                          style: kCardDescription,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                child: SizedBox(
                                  width: 100,
                                  height: double.infinity,
                                  child: _buildCategoriaImagen(categoria.imagen),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Botón fijo abajo
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: botonHabilitado ? _continuar : null,
                  style: kWhiteButtonStyle,
                  child: Text(
                    _cargandoChequeo
                        ? 'Verificando...'
                        : _hayPalabras
                            ? 'Jugar'
                            : 'No hay palabras en las categorías seleccionadas',
                    style: kWhiteButtonText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCategoriaImagen(String imagen) {
    if (imagen.isEmpty) {
      return _placeholderImagen();
    }

    // Imagen desde assets
    if (imagen.startsWith('assets/')) {
      return Image.asset(
        imagen,
        width: 100,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholderImagen(),
      );
    }

    // Imagen desde archivo local
    final file = File(imagen);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 100,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholderImagen(),
      );
    }

    return _placeholderImagen();
  }

  Widget _placeholderImagen() {
    return Container(
      width: 100,
      color: kGrayLight,
      child: const Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.white54,
      ),
    );
  }



}
