//Pantalla principal del juego

import 'package:flutter/material.dart';
import '../constants/ui_constants.dart'; //Para obtener el estilo del juego
import 'categoria_screen.dart';
import 'palabras_screen.dart';
import 'list_palabras_screen.dart';
import 'jugadores_screen.dart';
import '../widgets/primary_black_button.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: const BoxDecoration(
              gradient: kBackgroundGradient,
            ),
            width: double.infinity,
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 120),
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
                        const SizedBox(height: 80),

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

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

