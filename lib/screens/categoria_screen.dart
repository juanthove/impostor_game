import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../db/database_helper.dart';
import '../models/categoria.dart';
import '../utils/system_ui_helper.dart';
import '../constants/ui_constants.dart';
import '../widgets/primary_black_text_field.dart';

class AddCategoriaScreen extends StatefulWidget {
  const AddCategoriaScreen({super.key});

  @override
  State<AddCategoriaScreen> createState() => _AddCategoriaScreenState();
}

class _AddCategoriaScreenState extends State<AddCategoriaScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final DatabaseHelper db = DatabaseHelper.instance;

  final ImagePicker _picker = ImagePicker();
  File? _imagenSeleccionada;

  int? _categoriaIdSeleccionada;
  List<Categoria> _categorias = [];
  List<Map<String, dynamic>> _categoriasConCantidad = [];

  @override
  void initState() {
    super.initState();
    SystemUIHelper.hideSystemBars();
    _cargarCategorias();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Categoria _categoriaActual() {
    return _categorias.firstWhere(
      (c) => c.id == _categoriaIdSeleccionada,
    );
  }

  Future<void> _guardarCategoria() async {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();

    if (nombre.isEmpty || descripcion.isEmpty) {
      _mostrarMensaje('Complete todos los campos');
      return;
    }

    String imagenPath;

    // Imagen nueva
    if (_imagenSeleccionada != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = _imagenSeleccionada!.path.split('/').last;
      final savedImage =
          await _imagenSeleccionada!.copy('${appDir.path}/$fileName');
      imagenPath = savedImage.path;
    }
    // Editando y no cambió imagen
    else if (_categoriaIdSeleccionada != null) {
      imagenPath = _categoriaActual().imagen;
    }
    // Nueva sin imagen
    else {
      _mostrarMensaje('Debe seleccionar una imagen');
      return;
    }

    if (_categoriaIdSeleccionada == null) {
      // NUEVA
      final categoria = Categoria(
        nombre: nombre,
        descripcion: descripcion,
        imagen: imagenPath,
      );

      final id = await db.insertCategoriaSinDuplicar(categoria);
      if (id == null) {
        _mostrarMensaje('La categoría ya existe');
        return;
      }

      _mostrarMensaje('Categoría creada');
    } else {
      // EDITAR
      await db.updateCategoria(
        Categoria(
          id: _categoriaIdSeleccionada,
          nombre: nombre,
          descripcion: descripcion,
          imagen: imagenPath,
        ),
      );

      _mostrarMensaje('Categoría actualizada');
    }

    _resetFormulario();
    _cargarCategorias();
  }

  Future<void> _eliminarCategoria() async {
    final categoria = _categoriaActual();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kGrayField,
        title: const Text('Eliminar categoría',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "${categoria.nombre}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await db.deleteCategoria(categoria.id!);
      _resetFormulario();
      _cargarCategorias();
      _mostrarMensaje('Categoría eliminada');
    }
  }

  void _resetFormulario() {
    setState(() {
      _categoriaIdSeleccionada = null;
      _nombreController.clear();
      _descripcionController.clear();
      _imagenSeleccionada = null;
    });
  }

  Future<void> _cargarCategorias() async {
    final data = await db.getCategoriasConCantidadPalabras();

    setState(() {
      _categoriasConCantidad = data;

      // Seguimos necesitando la lista de Categoria para editar
      _categorias = data.map((e) => Categoria.fromMap(e)).toList();
    });
  }


  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagenSeleccionada = File(pickedFile.path));
    }
  }

  Widget _buildImagen() {
    if (_imagenSeleccionada != null) {
      return Image.file(_imagenSeleccionada!,
          width: 150, height: 150, fit: BoxFit.cover);
    }

    if (_categoriaIdSeleccionada != null) {
      final path = _categoriaActual().imagen;

      if (path.startsWith('assets/')) {
        return Image.asset(path,
            width: 150, height: 150, fit: BoxFit.cover);
      }

      return Image.file(File(path),
          width: 150, height: 150, fit: BoxFit.cover);
    }

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: kGrayField,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.photo_camera_outlined,
          color: Colors.white54, size: 48),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Agregar categoría', style: kTitleAppBar),
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== CONTENIDO SCROLLEABLE =====
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<int?>(
                        initialValue: _categoriaIdSeleccionada,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('➕ Nueva categoría'),
                          ),
                          ..._categoriasConCantidad.map(
                            (c) => DropdownMenuItem<int?>(
                              value: c['id'] as int,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(c['nombre']),
                                  Text(
                                    c['cantidad_palabras'].toString(),
                                    style: const TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        selectedItemBuilder: (context) {
                          return [
                            const Text('➕ Nueva categoría'),
                            ..._categoriasConCantidad.map(
                              (c) => Text(
                                '${c['nombre']} (${c['cantidad_palabras']})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ];
                        },
                        onChanged: (value) {
                          setState(() {
                            _categoriaIdSeleccionada = value;
                            _imagenSeleccionada = null;

                            if (value == null) {
                              _nombreController.clear();
                              _descripcionController.clear();
                            } else {
                              final c = _categoriaActual();
                              _nombreController.text = c.nombre;
                              _descripcionController.text = c.descripcion;
                            }
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: kGrayField,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownColor: Colors.grey.shade900,
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 16),

                      PrimaryBlackTextField(
                        controller: _nombreController,
                        hint: 'Nombre',
                      ),

                      const SizedBox(height: 16),

                      PrimaryBlackTextField(
                        controller: _descripcionController,
                        hint: 'Descripción',
                        capitalization: TextCapitalization.sentences,
                      ),

                      const SizedBox(height: 24),

                      _buildImagen(),

                      TextButton.icon(
                        icon: const Icon(Icons.image, color: Colors.white),
                        label: const Text(
                          'Seleccionar imagen',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _seleccionarImagen,
                      ),
                    ],
                  ),
                ),
              ),

              // ===== BOTÓN ELIMINAR =====
              if (_categoriaIdSeleccionada != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A1E1E), // bordó oscuro
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _eliminarCategoria,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_forever, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Eliminar categoría', style: kBlackButtonText),
                        ],
                      ),
                    ),
                  ),
                ),

              // ===== BOTÓN GUARDAR =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardarCategoria,
                    style: kBlackButtonStyle,
                    child: const Text(
                      'Guardar',
                      style: kBlackButtonText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
