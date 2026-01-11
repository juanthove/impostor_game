import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../db/database_helper.dart';
import '../models/categoria.dart';
import '../utils/system_ui_helper.dart'; //Ocultar barra de navegación
import '../constants/ui_constants.dart'; //Constantes de diseño
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
  File? _imagenSeleccionada;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    SystemUIHelper.hideSystemBars();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarCategoria() async {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();

    if (nombre.isEmpty || descripcion.isEmpty || _imagenSeleccionada == null) {
      _mostrarMensaje('Complete todos los campos e imagen');
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = _imagenSeleccionada!.path.split('/').last;
    final savedImage = await _imagenSeleccionada!.copy('${appDir.path}/$fileName');

    final categoria = Categoria(
      nombre: nombre,
      descripcion: descripcion,
      imagen: savedImage.path,
    );

    final id = await db.insertCategoriaSinDuplicar(categoria);

    if (id == null) {
      _mostrarMensaje('La categoría ya existe');
    } else {
      _mostrarMensaje('Categoría guardada');
      _nombreController.clear();
      _descripcionController.clear();
      setState(() {
        _imagenSeleccionada = null;
      });
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
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
          'Agregar categoría',
          style: kTitleAppBar,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: kBackgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Contenido scrollable
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100), // espacio para botón
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16), // separación inicial
                    // Campo Nombre
                    PrimaryBlackTextField(
                      controller: _nombreController,
                      hint: 'Nombre',
                    ),
                    const SizedBox(height: 16),

                    // Campo Descripción
                    PrimaryBlackTextField(
                      controller: _descripcionController,
                      hint: 'Descripción',
                    ),
                    const SizedBox(height: 24),

                    // Imagen
                    _imagenSeleccionada != null
                        ? Image.file(
                            _imagenSeleccionada!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: kGrayField,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.photo_camera_outlined,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
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

              // Botón Guardar fijo abajo
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _guardarCategoria,
                    style: kBlackButtonStyle,
                    child: const Text('Guardar', style: kBlackButtonText),
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

