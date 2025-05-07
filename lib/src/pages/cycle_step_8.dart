import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import 'package:google_fonts/google_fonts.dart';

class CycleStep8Page extends StatefulWidget {
  const CycleStep8Page({super.key});

  @override
  State<CycleStep8Page> createState() => _CycleStep8PageState();
}

class _CycleStep8PageState extends State<CycleStep8Page> {
  final FlutterTts _tts = FlutterTts();
  bool isPlaying = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupTTS();
  }

  Future<void> _setupTTS() async {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    final String ttsLang = localization.currentLanguage == 'es' ? 'es-MX' : 'es-MX';
    await _tts.setLanguage(ttsLang);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    
    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          isPlaying = false;
          isLoading = false;
        });
      }
    });
  }

  void _toggleAudio(LocalizationService localization) async {
    final String textToRead = localization.translate('step_8_description');

    if (isPlaying) {
      await _tts.stop();
      setState(() {
        isPlaying = false;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = true);
      try {
        await _tts.speak(textToRead);
        if (mounted) {
          setState(() {
            isPlaying = true;
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isPlaying = false;
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localization.translate('audio_error')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localization, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFA8D5BA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFDAB78D),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () {
                _tts.stop();
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Paso 8\n🔥 Selección de Terrenos o Parcela Forestales',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleAudio(localization),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[400],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 28, color: Colors.white),
                    label: Text(
                      isLoading
                          ? localization.translate('loading')
                          : isPlaying
                              ? localization.translate('stop_audio')
                              : localization.translate('play_audio'),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Imagen de ejemplo',
                  style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/step_8_img.png',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'Error: Imagen no encontrada',
                        style: GoogleFonts.montserrat(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 8),
                          Text(
                            'Descripción de la etapa:',
                            style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Antes de iniciar un nuevo ciclo de siembra, es crucial seleccionar semillas de calidad para garantizar una cosecha óptima.\n',
                        style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                      ),
                      Text(
                        'Los pasos clave de esta etapa incluyen:',
                        style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Selección de semillas sanas y resistentes: Se eligen semillas sin daños, con buen tamaño y color homogéneo.\n'
                        '• Prueba de viabilidad: Algunas semillas se sumergen en agua para verificar su flotabilidad; las que flotan suelen ser descartadas.\n'
                        '• Tratamientos previos: Algunas semillas son remojadas en soluciones nutritivas o tratadas con fertilizantes naturales para mejorar su crecimiento.\n',
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black87, height: 1.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Una selección adecuada de semillas ayuda a obtener plantas más fuertes y resistentes a enfermedades, asegurando una producción agrícola sostenible.',
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black87, height: 1.7),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
