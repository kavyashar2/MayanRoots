import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class CycleStep1Page extends StatefulWidget {
  const CycleStep1Page({super.key});

  @override
  _CycleStep1PageState createState() => _CycleStep1PageState();
}

class _CycleStep1PageState extends State<CycleStep1Page> {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupTTS();
  }

  Future<void> _setupTTS() async {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    // Set language based on current app language
    String ttsLang;
    switch (localization.currentLanguage) {
      case 'es':
        ttsLang = 'es-MX';
        break;
      case 'en':
        ttsLang = 'en-US';
        break;
      case 'yua':
        ttsLang = 'es-MX'; // Fallback for TTS if ever used directly for YUA
        break;
      default:
        ttsLang = 'es-MX'; // Default fallback
    }
    await _tts.setLanguage(ttsLang);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _audioPlayer.setVolume(1.0);
    
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
    final localization = Provider.of<LocalizationService>(context, listen: false);

    if (localization.currentLanguage == 'yua') {
      const String yucatecAudioPath = 'audio/yuc_step1_audio.mp3';

      if (isPlaying) {
        print('🔊 [DEBUG] Stopping Mayan MP3: assets/$yucatecAudioPath');
        await _audioPlayer.stop();
        if (mounted) {
          setState(() {
            isPlaying = false;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => isLoading = true);
        }
        try {
          print('🔊 [DEBUG] Attempting to play Mayan MP3: assets/$yucatecAudioPath');
          await _audioPlayer.play(AssetSource(yucatecAudioPath));
          if (mounted) {
            setState(() {
              isPlaying = true;
              isLoading = false;
            });
          }
          _audioPlayer.onPlayerComplete.first.then((_) {
            if (mounted) {
              setState(() {
                isPlaying = false;
              });
            }
          });
        } catch (e) {
          print('Error playing MP3 for YUA: $e');
          if (mounted) {
            setState(() {
              isLoading = false;
              isPlaying = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error playing audio file: ${e.toString()}'), backgroundColor: Colors.red),
            );
          }
        }
      }
      return;
    }

    // --- STANDARD TTS FOR OTHER LANGUAGES (EN, ES) ---
    print('🔊 [DEBUG] Audio button pressed for ${localization.currentLanguage}');
    
    // Construct text from granular segments for TTS for Step 1
    List<String> segmentsToSpeak = [
      localization.translate('step_1_desc_segment_1'),
      localization.translate('step_1_desc_segment_2_prefix'),
      localization.translate('step_1_desc_segment_2_suffix'),
      localization.translate('step_1_desc_segment_3_prefix'),
      localization.translate('step_1_desc_segment_3_suffix'),
    ];
    final String textToRead = segmentsToSpeak.where((s) => s.isNotEmpty && s != null).join(' '); // Join non-empty strings
    
    print('🔊 [DEBUG] Text to read for TTS: "$textToRead"');

    if (isPlaying) {
      print('🔊 [DEBUG] Stopping TTS');
      await _tts.stop();
      if (mounted) {
        setState(() {
          isPlaying = false;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
          setState(() => isLoading = true);
      }
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
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
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
                localization.translate('step_1_title'),
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
                      ? localization.translate('loading')
                      : isPlaying
                          ? localization.translate('stop_audio')
                          : localization.translate('play_audio'),
                  style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              localization.translate('example_image'),
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
                    localization.translate('image_load_error'),
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
                      Text('\u{1F333}', style: TextStyle(fontSize: 28)),
                      SizedBox(width: 8),
                      Text(
                        localization.translate('stage_description'),
                        style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\u{1F333}', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          localization.translate('step_1_desc_segment_1'),
                          style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\u{1F91D}', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                            children: [
                              TextSpan(text: localization.translate('step_1_desc_segment_2_prefix'), style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                              TextSpan(text: localization.translate('step_1_desc_segment_2_suffix')),
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
                      Text('\u{1F465}', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                            children: [
                              TextSpan(text: localization.translate('step_1_desc_segment_3_prefix'), style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                              TextSpan(text: localization.translate('step_1_desc_segment_3_suffix')),
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
