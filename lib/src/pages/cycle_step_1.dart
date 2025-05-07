import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/localization_service.dart';
import 'package:google_fonts/google_fonts.dart';

class CycleStep1Page extends StatefulWidget {
  const CycleStep1Page({super.key});

  @override
  _CycleStep1PageState createState() => _CycleStep1PageState();
}

class _CycleStep1PageState extends State<CycleStep1Page> {
  final FlutterTts _tts = FlutterTts();
  final _localization = LocalizationService.instance;
  bool isPlaying = false;
  bool isLoading = false;

  String t(String key) => _localization.translate(key);

  @override
  void initState() {
    super.initState();
    _setupTTS();
  }

  Future<void> _setupTTS() async {
    // Set language based on current app language
    final String ttsLang = _localization.currentLanguage == 'es' ? 'es-MX' : 'es-MX'; // Update when Maya TTS is available
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

  void _toggleAudio() async {
    print('🔊 [DEBUG] Audio button pressed');
    final String textToRead = t('step_1_description');
    print('🔊 [DEBUG] Text to read: $textToRead');

    if (isPlaying) {
      print('🔊 [DEBUG] Stopping TTS');
      await _tts.stop();
      setState(() {
        isPlaying = false;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = true);
      try {
        print('🔊 [DEBUG] Starting TTS.speak');
        var result = await _tts.speak(textToRead);
        print('🔊 [DEBUG] TTS.speak result: $result');
        if (mounted) {
          setState(() {
            isPlaying = true;
            isLoading = false;
          });
        }
      } catch (e) {
        print('🔊 [DEBUG] TTS error: $e');
        if (mounted) {
          setState(() {
            isPlaying = false;
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t('audio_error')),
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
            // Step name and emoji
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Step 1\n🌱 Selección de Terrenos o Parcelas Forestales',
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
                onPressed: _toggleAudio,
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
                'assets/images/step_1_img.png',
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
            // Description card with emoji, padding, and highlights
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
                      Text('🌱', style: TextStyle(fontSize: 28)),
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
                      Text('🌳', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                            children: [
                              TextSpan(text: 'La distribución de terrenos o parcelas forestales ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                              TextSpan(text: 'es el primer paso esencial en el ciclo agrícola. En esta etapa, los líderes de la comunidad, como los ancianos o el consejo comunal, asignan áreas específicas del bosque o terreno a diferentes familias o agricultores. Este proceso se basa en la tradición, el conocimiento local y las necesidades de la comunidad. '),
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
                      Text('🤝', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                            children: [
                              TextSpan(text: 'La distribución busca asegurar un uso equitativo y sostenible de la tierra, ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                              TextSpan(text: 'respetando los límites ecológicos y fomentando la regeneración del bosque en terrenos previamente utilizados.'),
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
                      Text('👥', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                            children: [
                              TextSpan(text: 'Este paso también refuerza el tejido social ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                              TextSpan(text: 'al involucrar a los miembros de la comunidad en decisiones colaborativas.'),
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
  }
}
