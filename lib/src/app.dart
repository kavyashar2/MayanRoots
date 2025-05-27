import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/localization_service.dart';
import 'pages/feedback_page.dart';
import 'maps_page.dart';
import 'agricultural_cycles_page.dart';
import 'pages/community_page.dart';
import 'pages/reports_page.dart';
import 'help_page.dart';
import 'pages/settings_page.dart';
import 'pages/cycle_step_1.dart';
import 'pages/cycle_step_2.dart';
import 'pages/cycle_step_3.dart';
import 'pages/cycle_step_4.dart';
import 'pages/cycle_step_5.dart';
import 'pages/cycle_step_6.dart';
import 'pages/cycle_step_7.dart';
import 'pages/cycle_step_8.dart';
import 'pages/forecast_year_selection_page.dart';
import 'dart:developer' as developer;
import 'widgets/scroll_down_indicator.dart';

void _log(String message) {
  final timestamp = DateTime.now().toIso8601String();
  final formattedMessage = '[$timestamp] 🎯 $message';
  debugPrint(formattedMessage);
  developer.log(message, name: 'AppUI');
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    _log('Building App widget');
    _log('Widget tree: App -> MyApp');
    return ChangeNotifierProvider<LocalizationService>.value(
      value: LocalizationService.instance,
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _log('Building MyApp widget');
    _log('Widget tree: MyApp -> Consumer<LocalizationService>');
    return Consumer<LocalizationService>(
      builder: (context, localization, _) {
        _log('Building MaterialApp with localization');
        _log('LocalizationService state:');
        _log('- initialized: ${localization.isInitialized}');
        _log('- currentLanguage: ${localization.currentLanguage}');
        _log('- isFirstLaunch: ${localization.isFirstLaunch}');
        
        if (!localization.isInitialized) {
          _log('⚠️ LocalizationService not initialized, showing loading screen');
          _log('Widget tree: MyApp -> MaterialApp -> LoadingScreen');
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        _log('Building full MaterialApp');
        _log('Widget tree: MyApp -> MaterialApp -> LanguageSelectionWrapper');
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mayan Roots App',
          theme: ThemeData(
            fontFamily: 'Montserrat',
            primarySwatch: Colors.brown,
            scaffoldBackgroundColor: const Color(0xFFA8D5BA),
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1.2),
              displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1.1),
              displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              bodyLarge: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500),
              bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
              labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          home: Builder(
            builder: (context) {
              _log('Building home widget (LanguageSelectionWrapper)');
              _log('Widget tree: MaterialApp -> Builder -> LanguageSelectionWrapper');
              return const LanguageSelectionWrapper();
            },
          ),
          routes: {
            '/cycle_step_1': (context) => const CycleStep1Page(),
            '/cycle_step_2': (context) => const CycleStep2Page(),
            '/cycle_step_3': (context) => const CycleStep3Page(),
            '/cycle_step_4': (context) => const CycleStep4Page(),
            '/cycle_step_5': (context) => const CycleStep5Page(),
            '/cycle_step_6': (context) => const CycleStep6Page(),
            '/cycle_step_7': (context) => const CycleStep7Page(),
            '/cycle_step_8': (context) => const CycleStep8Page(),
            '/maps': (context) => const MapsPage(),
            '/agricultural_cycles': (context) => const AgriculturalCyclesPage(),
            '/community': (context) => const CommunityPage(),
            '/reports': (context) => const ReportsPage(),
            '/help': (context) => const HelpPage(),
            '/settings': (context) => const SettingsPage(),
            '/forecast': (context) => const ForecastYearSelectionPage(),
          },
        );
      },
    );
  }
}

class LanguageSelectionWrapper extends StatefulWidget {
  const LanguageSelectionWrapper({super.key});

  @override
  State<LanguageSelectionWrapper> createState() => _LanguageSelectionWrapperState();
}

class _LanguageSelectionWrapperState extends State<LanguageSelectionWrapper> {
  final _localization = LocalizationService.instance;
  bool _showingDialog = false;

  @override
  void initState() {
    super.initState();
    _log('LanguageSelectionWrapper initState');
    _log('LocalizationService state:');
    _log('- initialized: ${_localization.isInitialized}');
    _log('- isFirstLaunch: ${_localization.isFirstLaunch}');
    _log('- currentLanguage: ${_localization.currentLanguage}');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _log('Post frame callback triggered');
      _checkAndShowLanguageDialog();
    });
  }

  Future<void> _checkAndShowLanguageDialog() async {
    _log('Checking if should show language dialog...');
    _log('Current state:');
    _log('- isFirstLaunch: ${_localization.isFirstLaunch}');
    _log('- showingDialog: $_showingDialog');
    _log('- currentLanguage: ${_localization.currentLanguage}');
    
    if (_localization.isFirstLaunch && !_showingDialog) {
      _log('Showing language dialog');
      setState(() => _showingDialog = true);
      await _showLanguageDialog();
    } else {
      _log('Skipping language dialog');
    }
  }

  Future<void> _showLanguageDialog() async {
    _log('Building language selection dialog');
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _log('Creating language dialog widget');
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Select Language / Selecciona el Idioma',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('Español', 'es'),
              const SizedBox(height: 16),
              _buildLanguageOption('Maya (Yucateco)', 'yua'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String label, String code) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA8D5BA),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () async {
        _log('Language option selected: $code');
        try {
          await _localization.setLanguage(code);
          _log('Language set successfully');
          if (mounted) {
            _log('Navigating to LandingPage');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LandingPage()),
            );
          }
        } catch (e, stack) {
          _log('❌ Error setting language:');
          _log('Error: $e');
          _log('Stack trace: $stack');
        }
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _log('Building LanguageSelectionWrapper');
    _log('Current state:');
    _log('- showingDialog: $_showingDialog');
    _log('- isFirstLaunch: ${_localization.isFirstLaunch}');
    _log('- currentLanguage: ${_localization.currentLanguage}');
    return const LandingPage();
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _log('LandingPage initState');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String t(String key) {
    return Provider.of<LocalizationService>(context).translate(key);
  }

  @override
  Widget build(BuildContext context) {
    _log('Building LandingPage widget (Reverted Style)');
    final localization = Provider.of<LocalizationService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFA8D5BA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFA8D5BA),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              _log('Settings button pressed, navigating to /settings');
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('preserving'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                            Text(t('heritage'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                            Text(t('yucatan'), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Image.asset(
                        'assets/images/Chaac-light 1.png',
                        height: 170,
                        width: 170,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  MenuItem(
                    label: t('maps'),
                    icon: Icons.map_outlined,
                    onTap: () => Navigator.pushNamed(context, '/maps'),
                  ),
                  MenuItem(
                    label: t('agricultural_cycles'),
                    icon: Icons.eco_outlined,
                    onTap: () => Navigator.pushNamed(context, '/agricultural_cycles'),
                  ),
                  MenuItem(
                    label: t('forecast_and_history'),
                    icon: Icons.cloud_outlined,
                    onTap: () => Navigator.pushNamed(context, '/forecast'),
                  ),
                   MenuItem(
                    label: t('community'),
                    icon: Icons.groups_outlined,
                    onTap: () => Navigator.pushNamed(context, '/community'),
                  ),
                  MenuItem(
                    label: t('reports'),
                    icon: Icons.insert_chart_outlined, 
                    onTap: () => Navigator.pushNamed(context, '/reports'),
                  ),
                  MenuItem(
                    label: t('help'),
                    icon: Icons.help_outline,
                    onTap: () => Navigator.pushNamed(context, '/help'),
                  ),
                  MenuItem(
                    label: t('settings'),
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),
          ScrollDownIndicator(controller: _scrollController),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const MenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15.0),
        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.black),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        overflow: TextOverflow.visible,
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '>',
              style: TextStyle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

// Make sure to add these new keys to your localization_service.dart:
// 'app_title': {'en': 'Mayan Roots', 'es': 'Raíces Mayas', 'yua': 'Mayab Ch'i'ibalo'ob'},
// 'main_slogan': {'en': 'Preserving the Heritage of Yucatán', 'es': 'Preservando la Herencia de Yucatán', 'yua': 'Táan k-kanáantik u kuxtal Yucatán'},
// 'maps_and_territory': {'en': 'Maps & Territory', 'es': 'Mapas y Territorio', 'yua': 'Mapas yéetel Lu'um'},
// 'agricultural_cycles': {'en': 'Agricultural Cycles', 'es': 'Ciclos Agrícolas', 'yua': 'Xookoy Paak''},
// 'community_and_collaborations': {'en': 'Community & Collaborations', 'es': 'Comunidad y Colaboraciones', 'yua': 'Múuch' Kaaj yéetel Múul Meyaj'},
// 'reports': {'en': 'Reports', 'es': 'Reportes', 'yua': 'Informes'},
// 'help_and_support': {'en': 'Help & Support', 'es': 'Ayuda y Soporte', 'yua': 'Áantaj yéetel Kanje'exil'},
// 'feedback': {'en': 'Feedback', 'es': 'Comentarios', 'yua': 'Tsolik Tuukul'}

// Also ensure 'assets/images/mayan_symbol.png' exists or update the path. 