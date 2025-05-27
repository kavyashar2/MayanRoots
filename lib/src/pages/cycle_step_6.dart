import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class CycleStep6Page extends StatefulWidget {
  const CycleStep6Page({super.key});

  @override
  State<CycleStep6Page> createState() => _CycleStep6PageState();
}

class _CycleStep6PageState extends State<CycleStep6Page> {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupTTS();
  }

  Future<void> _setupTTS() async {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    String ttsLang;
    switch (localization.currentLanguage) {
      case 'es':
        ttsLang = 'es-MX';
        break;
      case 'en':
        ttsLang = 'en-US';
        break;
      case 'yua':
        ttsLang = 'es-MX';
        break;
      default:
        ttsLang = 'es-MX';
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

  void _toggleAudio(LocalizationService localization) async {
    if (localization.currentLanguage == 'yua') {
      const String yucatecAudioPath = 'audio/yuc_step6_audio.mp3';
      if (isPlaying) {
        await _audioPlayer.stop();
        if (mounted) setState(() { isPlaying = false; isLoading = false; });
      } else {
        if (mounted) setState(() => isLoading = true);
        try {
          await _audioPlayer.play(AssetSource(yucatecAudioPath));
          if (mounted) setState(() { isPlaying = true; isLoading = false; });
          _audioPlayer.onPlayerComplete.first.then((_) {
            if (mounted) setState(() { isPlaying = false; });
          });
        } catch (e) {
          if (mounted) setState(() { isLoading = false; isPlaying = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing audio file: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      }
      return;
    }

    List<String> segmentsToSpeak = [
      localization.translate('step_6_desc_s1'),
      localization.translate('step_6_desc_s2'),
      localization.translate('step_6_bullet_1_title') + ' ' + localization.translate('step_6_bullet_1_text'),
      localization.translate('step_6_bullet_2_title') + ' ' + localization.translate('step_6_bullet_2_text'),
      localization.translate('step_6_bullet_3_title') + ' ' + localization.translate('step_6_bullet_3_text'),
      localization.translate('step_6_desc_s3'),
    ];
    final String textToRead = segmentsToSpeak.where((s) => s != null && s.isNotEmpty).join(' \n');

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
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildBulletPoint(LocalizationService localization, String titleKey, String textKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87, height: 1.7),
                children: [
                  TextSpan(text: localization.translate(titleKey), style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: localization.translate(textKey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                _audioPlayer.stop();
                Navigator.pop(context);
              },
            ),
            title: Text(localization.translate('step_6_title')),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    localization.translate('step_6_title'),
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
                    'assets/images/step_6_img.jpg',
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
                          Text('🔄', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 8),
                          Text(
                            localization.translate('stage_description'),
                            style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localization.translate('step_6_desc_s1'),
                        style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localization.translate('step_6_desc_s2'),
                        style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      
                      // Bullet point 1
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌱', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black, height: 1.5),
                                children: [
                                  TextSpan(
                                    text: localization.translate('step_6_bullet_1_title'),
                                    style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: ' ' + localization.translate('step_6_bullet_1_text')),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // Bullet point 2
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌱', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black, height: 1.5),
                                children: [
                                  TextSpan(
                                    text: localization.translate('step_6_bullet_2_title'),
                                    style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: ' ' + localization.translate('step_6_bullet_2_text')),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // Bullet point 3
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌱', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black, height: 1.5),
                                children: [
                                  TextSpan(
                                    text: localization.translate('step_6_bullet_3_title'),
                                    style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: ' ' + localization.translate('step_6_bullet_3_text')),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        localization.translate('step_6_desc_s3'),
                        style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
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
