import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/palabra.dart';
import '../models/categoria.dart';
import '../constants/ui_constants.dart';
import '../widgets/primary_black_text_field.dart';

class EditPalabraSheet extends StatefulWidget {
  final Palabra palabra;

  const EditPalabraSheet({
    super.key,
    required this.palabra,
  });

  @override
  State<EditPalabraSheet> createState() => _EditPalabraSheetState();
}

class _EditPalabraSheetState extends State<EditPalabraSheet> {
  final db = DatabaseHelper.instance;

  final TextEditingController _palabraController = TextEditingController();
  final List<TextEditingController> _pistasControllers = [];
  final List<FocusNode> _pistasFocusNodes = [];
  

  List<Categoria> _categorias = [];
  Categoria? _categoriaSeleccionada;

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final categorias = await db.getCategorias();
    final pistas = await db.getPistasPorPalabra(widget.palabra.id!);

    _palabraController.text = widget.palabra.texto;

    for (final p in pistas) {
      _pistasControllers.add(TextEditingController(text: p.texto));
      _pistasFocusNodes.add(FocusNode());
    }

    // 🔥 Si no tiene pistas, crear un campo vacío
    if (_pistasControllers.isEmpty) {
      _pistasControllers.add(TextEditingController());
      _pistasFocusNodes.add(FocusNode());
    }


    setState(() {
      _categorias = categorias;
      _categoriaSeleccionada = categorias.firstWhere(
        (c) => c.id == widget.palabra.categoriaId,
      );
      _cargando = false;
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

  void _eliminarPista(int index) {
    if (_pistasControllers.length == 1) {
      // 🔥 Solo limpiar el texto
      _pistasControllers.first.clear();
      return;
    }

    setState(() {
      _pistasControllers[index].dispose();
      _pistasFocusNodes[index].dispose();
      _pistasControllers.removeAt(index);
      _pistasFocusNodes.removeAt(index);
    });
  }



  Future<void> _guardarCambios() async {
    final texto = _palabraController.text.trim();

    if (texto.isEmpty || _categoriaSeleccionada == null) {
      _mostrarMensaje('Complete todos los campos');
      return;
    }

    final existe = await db.palabraExiste(
      texto: texto,
      categoriaId: _categoriaSeleccionada!.id!,
      excluirPalabraId: widget.palabra.id!,
    );

    if (existe) {
      _mostrarMensaje('Ya existe una palabra con ese nombre');
      return;
    }

    final pistas = _pistasControllers
        .map((c) => c.text.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    await db.updatePalabraConPistas(
      palabraId: widget.palabra.id!,
      texto: texto,
      categoriaId: _categoriaSeleccionada!.id!,
      pistas: pistas,
    );

    if(!mounted) return;

    Navigator.pop(context);
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: kGrayField,
        behavior: SnackBarBehavior.floating,
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
    // Mientras carga datos
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Container(
      // Limita la altura máxima del bottom sheet
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        gradient: kBackgroundGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // =========================================================
          // CONTENIDO (inputs + pistas)
          // =========================================================
          //
          // Usamos Expanded SOLO para empujar el botón al fondo.
          // El contenido interno se alinea arriba para que,
          // si hay poco contenido, no quede un hueco raro.
          //
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                // Padding interno del contenido
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  // Importante: no forzamos altura,
                  // se adapta al contenido real
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // =========================
                    // Campo Palabra
                    // =========================
                    PrimaryBlackTextField(
                      controller: _palabraController,
                      hint: 'Palabra',
                    ),
                    const SizedBox(height: 16),

                    // =========================
                    // Dropdown Categoría
                    // =========================
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
                        filled: true,
                        fillColor: kGrayField,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownColor: Colors.grey.shade900,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // =========================
                    // Lista de pistas
                    // =========================
                    //
                    // No scrollea por sí sola.
                    // El scroll lo maneja el SingleChildScrollView padre.
                    //
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pistasControllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              // Campo de texto de la pista
                              Expanded(
                                child: PrimaryBlackTextField(
                                  controller: _pistasControllers[index],
                                  focusNode: _pistasFocusNodes[index],
                                  hint: 'Pista ${index + 1}',
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Botón eliminar pista
                              Container(
                                decoration: const BoxDecoration(
                                  color: kGrayField,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _eliminarPista(index),
                                ),
                              ),

                              // Botón agregar pista (solo la última)
                              if (index == _pistasControllers.length - 1) ...[
                                const SizedBox(width: 6),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: kGrayField,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    onPressed: _agregarPista,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =========================================================
          // BOTÓN FIJO
          // =========================================================
          //
          // NO calculamos insets manuales.
          // El sistema mueve todo el sheet cuando aparece el teclado.
          //
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarCambios,
                style: kBlackButtonStyle,
                child: const Text(
                  'Guardar cambios',
                  style: kBlackButtonText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
