import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import 'package:google_fonts/google_fonts.dart';

class CycleStep2Page extends StatefulWidget {
  const CycleStep2Page({super.key});

  @override
  State<CycleStep2Page> createState() => _CycleStep2PageState();
}

class _CycleStep2PageState extends State<CycleStep2Page> {
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
    final String textToRead = localization.translate('step_2_description');

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
                    'Step 2\n🌾 Desmonte del Terreno (Corte de Vegetación)',
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
                      backgroundColor: Colors.brown,
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
                          ? 'Cargando...'
                          : isPlaying
                              ? 'Detener audio'
                              : 'Reproducir audio',
                      style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
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
                    'assets/images/step_2_img.jpg',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'No se pudo cargar la imagen',
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
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('🌾', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 8),
                          Text(
                            'Descripción de la etapa:',
                            style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🪓', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'El desmonte del terreno es el proceso de eliminación de la vegetación para preparar la tierra para la siembra.',
                              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌳', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Esto puede incluir la remoción de árboles, arbustos y maleza que puedan obstruir la producción agrícola.',
                              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🛠️', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Las técnicas utilizadas varían según la región y los recursos disponibles. En comunidades tradicionales, se emplean herramientas manuales como machetes, mientras que en sistemas agrícolas modernos se pueden usar máquinas pesadas para despejar grandes áreas.',
                              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌳', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Es importante llevar a cabo este proceso de manera responsable, preservando ciertos árboles para mantener la biodiversidad, evitar la erosión del suelo y asegurar la regeneración del ecosistema.',
                              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌱', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                                children: [
                                  TextSpan(text: 'Las prácticas '),
                                  TextSpan(text: 'sostenibles', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                                  TextSpan(text: ' buscan minimizar el impacto ambiental y garantizar la fertilidad del suelo para los siguientes ciclos de cultivo.'),
                                ],
                              ),
                            ),
                          ),
                        ],
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
