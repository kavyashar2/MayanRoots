import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import 'package:google_fonts/google_fonts.dart';

class CycleStep5Page extends StatefulWidget {
  const CycleStep5Page({super.key});

  @override
  State<CycleStep5Page> createState() => _CycleStep5PageState();
}

class _CycleStep5PageState extends State<CycleStep5Page> {
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
    final String textToRead = localization.translate('step_5_description');

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
                    'Step 5\n🌽 Mantenimiento y Deshierbe durante el crecimiento del cultivo',
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
                    'assets/images/step_5_img.jpg',
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
                          Text('🌽', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 8),
                          Text(
                            'Descripción de la etapa:',
                            style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Paragraph 1
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌱', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'El mantenimiento y deshierbe son esenciales para el crecimiento saludable de los cultivos. Durante esta fase, los agricultores eliminan las hierbas no deseadas que compiten con los cultivos por agua y nutrientes.',
                              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Bullet points
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🔹', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                                children: [
                                  TextSpan(text: 'Deshierbe manual o con herramientas tradicionales: ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                                  TextSpan(text: 'para evitar el uso excesivo de químicos.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🔹', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                                children: [
                                  TextSpan(text: 'Control de plagas y enfermedades: ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                                  TextSpan(text: 'asegurando que los cultivos crezcan sanos y sin interferencias.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🔹', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                                children: [
                                  TextSpan(text: 'Mantenimiento del suelo: ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                                  TextSpan(text: 'asegurando que retenga la humedad adecuada para el crecimiento óptimo de las plantas.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Paragraph 2
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌾', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Esta etapa es crucial para garantizar una cosecha abundante y sostenible, minimizando el impacto negativo en el ecosistema local.',
                              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
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
