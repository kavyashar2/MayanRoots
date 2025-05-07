import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the step pages
import 'pages/cycle_step_1.dart';
import 'pages/cycle_step_2.dart';
import 'pages/cycle_step_3.dart';
import 'pages/cycle_step_4.dart';
import 'pages/cycle_step_5.dart';
import 'pages/cycle_step_6.dart';
import 'pages/cycle_step_7.dart';
import 'pages/cycle_step_8.dart';

class AgriculturalCyclesPage extends StatelessWidget {
  const AgriculturalCyclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'title': 'Paso 1: Selección de Terrenos o Parcelas Forestales',
        'emoji': '🌱',
        'desc': 'Asignación de parcelas forestales a familias.',
        'img': 'assets/images/step_1_img.png',
        'page': const CycleStep1Page(),
      },
      {
        'title': 'Paso 2: Desmonte del Terreno (Corte de Vegetación)',
        'emoji': '🪓',
        'desc': 'Corte de vegetación y preparación inicial.',
        'img': 'assets/images/step_2_img.jpg',
        'page': const CycleStep2Page(),
      },
      {
        'title': 'Paso 3: Quema Controlada',
        'emoji': '🔥',
        'desc': 'Eliminación de residuos vegetales secos.',
        'img': 'assets/images/step_3_img.jpg',
        'page': const CycleStep3Page(),
      },
      {
        'title': 'Paso 4: Siembra de las Semillas',
        'emoji': '🌾',
        'desc': 'Plantación de semillas en el terreno preparado.',
        'img': 'assets/images/step_4_img.jpg',
        'page': const CycleStep4Page(),
      },
      {
        'title': 'Paso 5: Mantenimiento y Deshierbe durante el Crecimiento del Cultivo',
        'emoji': '🧑‍🌾',
        'desc': 'Cuidado y limpieza durante el crecimiento.',
        'img': 'assets/images/step_5_img.jpg',
        'page': const CycleStep5Page(),
      },
      {
        'title': 'Paso 6: Cosecha de los Cultivos',
        'emoji': '🌽',
        'desc': 'Recolección de los productos agrícolas.',
        'img': 'assets/images/step_6_img.png',
        'page': const CycleStep6Page(),
      },
      {
        'title': 'Paso 7: Limpieza del Terreno para un Nuevo Ciclo de Cultivo',
        'emoji': '🛖',
        'desc': 'Preparación del terreno para el siguiente ciclo.',
        'img': 'assets/images/step_7_img.png',
        'page': const CycleStep7Page(),
      },
      {
        'title': 'Paso 8: Selección de Terrenos o Parcela Forestales',
        'emoji': '🔥',
        'desc': 'Selección de semillas sanas y resistentes para asegurar una cosecha óptima y sostenible.',
        'img': 'assets/images/step_8_img.png',
        'page': const CycleStep8Page(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('El Ciclo Agrícola de la Milpa', style: GoogleFonts.montserrat()),
        backgroundColor: const Color(0xFFDAB78D),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFA8D5BA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: steps.length,
          itemBuilder: (context, idx) {
            final step = steps[idx];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => step['page'] as Widget),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Text(step['emoji'] as String, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        step['title'] as String,
                        style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        step['desc'] as String,
                        style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black87),
                        textAlign: TextAlign.center,
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}