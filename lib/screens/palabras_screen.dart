//Pantalla para insertar palabras
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/categoria.dart';
import '../utils/system_ui_helper.dart';
import '../constants/ui_constants.dart';
import '../widgets/primary_black_text_field.dart';

class AddPalabraScreen extends StatefulWidget {
  const AddPalabraScreen({super.key});

  @override
  State<AddPalabraScreen> createState() => _AddPalabraScreenState();
}

class _AddPalabraScreenState extends State<AddPalabraScreen> {
  final TextEditingController _palabraController = TextEditingController();
  final DatabaseHelper db = DatabaseHelper.instance;

  List<Categoria> _categorias = [];
  Categoria? _categoriaSeleccionada;

  final List<TextEditingController> _pistasControllers = [TextEditingController()];
  final List<FocusNode> _pistasFocusNodes = [FocusNode()];

  @override
  void initState() {
    super.initState();
    SystemUIHelper.hideSystemBars();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final categorias = await db.getCategorias();
    setState(() {
      _categorias = categorias;
      if (categorias.isNotEmpty) _categoriaSeleccionada = categorias.first;
    });
  }

  void _agregarPista() {
    setState(() {
      _pistasControllers.add(TextEditingController());
      _pistasFocusNodes.add(FocusNode());
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _pistasFocusNodes.last.requestFocus();
    });
  }

  Future<void> _guardarPalabra() async {
    final texto = _palabraController.text.trim();

    if (texto.isEmpty || _categoriaSeleccionada == null) {
      _mostrarMensaje('Complete todos los campos');
      return;
    }

    final pistas = _pistasControllers
        .map((c) => c.text.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    final id = await db.insertarPalabraConPistas(
      texto: texto,
      categoriaId: _categoriaSeleccionada!.id!,
      pistas: pistas,
    );

    if (id == null) {
      _mostrarMensaje('La palabra ya existe');
    } else {
      _mostrarMensaje('Palabra guardada');
      _palabraController.clear();
      for (final c in _pistasControllers) {
        c.clear();
      }
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: kGrayField,
      ),
    );
  }

  @override
  void dispose() {
    _palabraController.dispose();
    for (final c in _pistasControllers) {
      c.dispose();
    }
    for (final f in _pistasFocusNodes) {
      f.dispose();
    }
    super.dispose();
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
        title: const Text(
          'Agregar palabra',
          style: kTitleAppBar,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
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
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100), // espacio para el botón
                child: Column(
                  children: [
                    // Campo palabra
                    PrimaryBlackTextField(
                      controller: _palabraController,
                      hint: 'Palabra',
                    ),
                    const SizedBox(height: 16),

                    // Dropdown categoría
                    DropdownButtonFormField<Categoria>(
                      initialValue: _categoriaSeleccionada,
                      items: _categorias
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _categoriaSeleccionada = value;
                        });
                      },
                      iconEnabledColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Categoría',
                        filled: true,
                        fillColor: kGrayField,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.grey.shade900,
                    ),
                    const SizedBox(height: 16),

                    // Lista de pistas
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pistasControllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: PrimaryBlackTextField(
                                  controller: _pistasControllers[index],
                                  focusNode: _pistasFocusNodes[index],
                                  hint: 'Pista ${index + 1}',
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (index == _pistasControllers.length - 1)
                                Container(
                                  decoration: const BoxDecoration(
                                    color: kGrayField,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    onPressed: _agregarPista,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Botón guardar fijo abajo
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _guardarPalabra,
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
