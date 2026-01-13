// Pantalla principal del juego
import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import 'categoria_screen.dart';
import 'palabras_screen.dart';
import 'list_palabras_screen.dart';
import 'jugadores_screen.dart';
import '../widgets/primary_black_button.dart';
import '../widgets/opcion_button.dart';
import '../widgets/primary_black_action_button.dart';
import '../db/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'legal_web_screen.dart';


enum OpcionesView {
  main,
  resetData,
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  //URL legal
  static const String urlPrivacy = 'https://juanthove.github.io/impostor-game-legal/';
  static const String urlTerms = 'https://juanthove.github.io/impostor-game-legal/#terms';

  
  void _abrirOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false, // 👈 no se cierra al arrastrar
      backgroundColor: Colors.transparent,
      builder: (_) {
        OpcionesView view = OpcionesView.main;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF5A5F),
                    Color(0xFFD32F2F),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 👈 CLAVE
                  children: [
                    _handle(),
                    const SizedBox(height: 16),

                    const Text(
                      'Opciones',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 👇 SOLO ESTA ZONA CRECE / SCROLLEA
                    Flexible(
                      fit: FlexFit.loose,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: view == OpcionesView.main
                            ? _vistaOpcionesMain(
                              context: context,
                                key: const ValueKey('main'),
                                onResetTap: () {
                                  setState(() {
                                    view = OpcionesView.resetData;
                                  });
                                },
                              )
                            : _vistaResetData(
                                context: context,
                                key: const ValueKey('reset'),
                                onBack: () {
                                  setState(() {
                                    view = OpcionesView.main;
                                  });
                                },
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    PrimaryBlackActionButton(
                      texto: view == OpcionesView.main ? 'Cerrar' : 'Atrás',
                      onPressed: () {
                        if (view == OpcionesView.main) {
                          Navigator.pop(context); // cerrar modal
                        } else {
                          setState(() {
                            view = OpcionesView.main; // volver atrás
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _vistaOpcionesMain({
    required BuildContext context, // ⚡ agregar context
    required Key key,
    required VoidCallback onResetTap,
  }) {
    return SingleChildScrollView(
      key: key,
      child: Column(
        children: [
          OpcionButton(
            texto: 'Contáctanos',
            icono: Icons.email_outlined,
            onTap: () => _abrirCorreo(),
          ),
          OpcionButton(
            texto: 'Política de privacidad',
            icono: Icons.shield_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LegalWebViewScreen(
                    url: urlPrivacy,
                  ),
                ),
              );
            },
          ),
          OpcionButton(
            texto: 'Términos de uso',
            icono: Icons.description_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LegalWebViewScreen(
                    url: urlTerms,
                  ),
                ),
              );
            },
          ),
          OpcionButton(
            texto: 'Reiniciar datos',
            icono: Icons.restart_alt,
            onTap: onResetTap,
          ),

          const SizedBox(height: 12),

          const Text(
            'Versión: 1.0.0',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }


  Widget _vistaResetData({
    required BuildContext context,
    required Key key,
    required VoidCallback onBack,
  }) {
    return SingleChildScrollView(
      key: key,
      child: Column(
        children: [
          OpcionButton(
            texto: 'Reiniciar todo',
            icono: Icons.warning_amber_rounded,
            onTap: () async {
              final confirmar = await _mostrarConfirmacion(
                context,
                titulo: 'Reiniciar todos los datos',
                mensaje:
                    'Esta acción eliminará TODAS las categorías y palabras registradas '
                    'y restaurará los datos iniciales de la aplicación.\n\n'
                    '⚠️ Esta acción no se puede deshacer.',
                textoConfirmar: 'Reiniciar',
              );

              if (confirmar == true) {
                // 👉 ACÁ VA LA ACCIÓN
                await DatabaseHelper.instance.resetTodo();
              }
            },
          ),

          OpcionButton(
            texto: 'Mantener categorías y palabras',
            icono: Icons.save_outlined,
            onTap: () async {
              final confirmar = await _mostrarConfirmacion(
                context,
                titulo: 'Restaurar datos iniciales',
                mensaje:
                    'Se restaurarán los datos iniciales de la aplicación, '
                    'pero se mantendrán las categorías y palabras que agregaste.\n\n'
                    '¿Deseas continuar?',
                textoConfirmar: 'Restaurar',
                colorConfirmar: Colors.orange,
              );

              if (confirmar == true) {
                // 👉 ACÁ VA LA ACCIÓN
                await DatabaseHelper.instance.restaurarDatosIniciales();
              }
            },
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }


 Future<bool?> _mostrarConfirmacion(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    required String textoConfirmar,
    Color colorConfirmar = Colors.red,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kGrayField,
        title: Text(
          titulo,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          mensaje,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              textoConfirmar,
              style: TextStyle(color: colorConfirmar),
            ),
          ),
        ],
      ),
    );
  }


  Widget _handle() {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Future<void> _abrirCorreo() async {
    final Uri emailUri = Uri.parse(
      'mailto:contacto@tuapp.com'
      '?subject=Contacto desde la app Impostor'
      '&body=Hola,%0A%0AQuiero comunicarme por lo siguiente:%0A',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint('No hay app de correo disponible');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18), //Mover a la izquierda la rueda
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 32, //Tamaño de la rueda
              ),
              onPressed: () => _abrirOpciones(context),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kBackgroundGradient,
        ),
        width: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 1),

                const Text(
                  'IMPOSTOR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const Spacer(),

                PrimaryBlackButton(
                  texto: 'Agregar categorías',
                  screen: const AddCategoriaScreen(),
                ),
                const SizedBox(height: 16),
                PrimaryBlackButton(
                  texto: 'Agregar palabras',
                  screen: const AddPalabraScreen(),
                ),
                const SizedBox(height: 16),
                PrimaryBlackButton(
                  texto: 'Listado de palabras',
                  screen: const ListPalabrasScreen(),
                ),
                const SizedBox(height: 16),
                PrimaryBlackButton(
                  texto: 'Jugar',
                  screen: const JugadoresScreen(),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
