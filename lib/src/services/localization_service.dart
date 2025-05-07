import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static LocalizationService? _instance;
  SharedPreferences? _prefs;
  String _currentLanguage = 'yua'; // Default to Yucatec Maya
  bool _isInitialized = false;
  
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final formattedMessage = '[$timestamp] 📚 $message';
    debugPrint(formattedMessage);
    developer.log(message, name: 'LocalizationService');
  }
  
  // Private constructor
  LocalizationService._() {
    _log('LocalizationService private constructor called');
  }
  
  // Singleton pattern with lazy initialization
  static LocalizationService get instance {
    if (_instance == null) {
      debugPrint('[${'Creating new LocalizationService instance'}] 📚');
      _instance = LocalizationService._();
    }
    return _instance!;
  }

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _log('Starting LocalizationService initialization');
    _log('Current state:');
    _log('- _isInitialized: $_isInitialized');
    _log('- _currentLanguage: $_currentLanguage');
    _log('- _prefs: ${_prefs != null ? "initialized" : "null"}');
    
    if (_isInitialized) {
      _log('LocalizationService already initialized, skipping');
      return;
    }
    
    try {
      _log('Attempting to get SharedPreferences instance');
      _prefs = await SharedPreferences.getInstance();
      _log('SharedPreferences instance obtained successfully');
      _log('SharedPreferences keys: ${_prefs?.getKeys().join(", ")}');
      
      final savedLanguage = _prefs?.getString(_languageKey);
      _log('Saved language from preferences: $savedLanguage');
      
      _currentLanguage = savedLanguage ?? 'yua';
      _log('Current language set to: $_currentLanguage');
      
      _isInitialized = true;
      _log('LocalizationService initialization complete');
      _log('Final state:');
      _log('- _isInitialized: $_isInitialized');
      _log('- _currentLanguage: $_currentLanguage');
      _log('- _prefs: ${_prefs != null ? "initialized" : "null"}');
      notifyListeners();
    } catch (e, stack) {
      _log('❌ Failed to initialize LocalizationService:');
      _log('Error: $e');
      _log('Stack trace: $stack');
      _log('Failed state:');
      _log('- _isInitialized: $_isInitialized');
      _log('- _currentLanguage: $_currentLanguage');
      _log('- _prefs: ${_prefs != null ? "initialized" : "null"}');
      rethrow;
    }
  }

  String get currentLanguage => _currentLanguage;

  Future<void> setLanguage(String languageCode) async {
    _log('Attempting to set language to: $languageCode');
    
    if (!_isInitialized) {
      _log('❌ Error: LocalizationService not initialized');
      throw StateError('LocalizationService not initialized');
    }
    
    if (!_translations.containsKey(languageCode)) {
      _log('❌ Error: Invalid language code: $languageCode');
      return;
    }
    
    try {
      _log('Saving language preference');
      await _prefs?.setString(_languageKey, languageCode);
      _currentLanguage = languageCode;
      _log('Language successfully set to: $languageCode');
      notifyListeners();
    } catch (e, stack) {
      _log('❌ Failed to set language:');
      _log('Error: $e');
      _log('Stack trace: $stack');
      rethrow;
    }
  }

  bool get isFirstLaunch {
    final result = _prefs?.containsKey(_languageKey) == false;
    _log('Checking if first launch: $result');
    return result;
  }

  String translate(String key) {
    if (!_isInitialized) {
      _log('⚠️ Warning: LocalizationService not initialized, returning key as fallback');
      return key;
    }
    
    final translation = _translations[_currentLanguage]?[key] ?? key;
    _log('Translating key: $key to: $translation (language: $_currentLanguage)');
    return translation;
  }
}

// Translations map
final _translations = {
  'es': {
    // Landing Page
    'preserving': 'Preservando el',
    'heritage': 'Patrimonio de',
    'yucatan': 'Yucatán',
    'maps': 'Mapas',
    'agricultural_cycles': 'Ciclos Agrícolas',
    'community': 'Comunidad',
    'reports': 'Reportes',
    'help': 'Ayuda',
    'settings': 'Configuración',

    // Reports Page
    'reports_title': 'Reportes',
    'new_report': 'Crear Nuevo Reporte',
    'report_name': 'Nombre del Reporte',
    'report_name_hint': 'Ejemplo: Plagas en el maíz, Problema de riego.',
    'report_name_error': 'Por favor ingrese un nombre para el reporte',
    'category': 'Categoría',
    'description': 'Descripción del Problema',
    'description_hint': 'Describa el problema en detalle...',
    'description_error': 'Por favor ingrese una descripción',
    'location': 'Ubicación general (Opcional)',
    'location_hint': 'Ejemplo: Parcela norte, Sector 3',
    'crop_yield': 'Rendimiento del cultivo (Opcional)',
    'crop_yield_hint': 'Ejemplo: 2 toneladas por hectárea',
    'incident_date': 'Fecha del Incidente',
    'submit': 'Enviar Reporte',
    'success': 'Reporte enviado con éxito',
    'error': 'Error al enviar el reporte',
    'try_again': 'Intentar de Nuevo',

    // Agricultural Cycles Page
    'agricultural_cycles_title': 'Ciclos Agrícolas',
    'welcome_cycles': 'Bienvenido a la página de Ciclos Agrícolas',
    'cycles_description': 'Toca los números para aprender más sobre cada paso del proceso agrícola.',
    'continue': 'Continuar',
    'example_image': 'Imagen de ejemplo',
    'stage_description': 'Descripción de la etapa:',
    'play_audio': 'Reproducir audio',

    // Agricultural Cycle Steps
    'step_1_title': 'Selección de Terrenos o Parcelas Forestales',
    'step_1_description': 'La distribución de terrenos o parcelas forestales es el primer paso esencial en el ciclo agrícola. En esta etapa, los líderes de la comunidad, como los ancianos o el consejo comunal, asignan áreas específicas del bosque o terreno a diferentes familias o agricultores. Este proceso se basa en la tradición, el conocimiento local y las necesidades de la comunidad.',
    
    'step_2_title': 'Desmonte del Terreno (Corte de Vegetación)',
    'step_2_description': 'En esta etapa se prepara el terreno eliminando la vegetación existente. Es un proceso tradicional que requiere conocimiento específico para minimizar el impacto ambiental.',
    
    'step_3_title': 'Quema Controlada',
    'step_3_description': 'La quema controlada es una técnica tradicional que requiere experiencia y cuidado. Durante esta fase, los agricultores realizan una quema controlada del material vegetal seco, siguiendo prácticas ancestrales que minimizan riesgos y aprovechan los nutrientes para el suelo.',
    
    'step_4_title': 'Siembra de las Semillas',
    'step_4_description': 'La siembra de semillas marca el inicio del cultivo en el ciclo agrícola. Durante esta fase, los agricultores seleccionan las mejores semillas y las plantan en el suelo preparado.\n\nLos factores clave en esta etapa incluyen:\n• Selección de semillas: Se eligen variedades adaptadas al clima y tipo de suelo.\n• Preparación del suelo: Se remueve la tierra y se aseguran las condiciones óptimas para la germinación.\n• Técnicas de siembra: Dependiendo de la comunidad, se pueden utilizar métodos tradicionales o técnicas modernas como la siembra directa.',
    
    'step_5_title': 'Crecimiento de las Plantas',
    'step_5_description': 'El crecimiento de las plantas es una fase crucial que requiere cuidado y atención constante. Durante este período, los agricultores monitorean y nutren los cultivos para asegurar un desarrollo saludable.\n\nAspectos importantes durante esta etapa:\n• Riego regular: Mantener la humedad adecuada del suelo.\n• Control de malezas: Eliminar plantas no deseadas que compiten por nutrientes.\n• Monitoreo de plagas: Vigilar y proteger los cultivos de posibles amenazas.',
    
    'step_6_title': 'Floración',
    'step_6_description': 'La floración es una etapa crucial en el ciclo agrícola, donde las plantas desarrollan sus flores, que eventualmente se convertirán en frutos o granos.\n\nDurante esta fase:\n• Las plantas requieren condiciones específicas de luz y temperatura.\n• Es importante mantener un riego adecuado sin excesos.\n• Se debe proteger las flores de plagas y condiciones climáticas adversas.',
    
    'step_7_title': 'Cosecha',
    'step_7_description': 'La cosecha es una de las etapas más importantes en el ciclo agrícola. En este proceso, los agricultores recolectan los cultivos maduros asegurándose de preservar la calidad del producto.\n\nLos factores clave de esta etapa incluyen:\n• Método de cosecha: Dependiendo del tipo de cultivo, la recolección puede ser manual o con herramientas y maquinaria especializada.\n• Momento adecuado: Se determina según la madurez del cultivo y las condiciones climáticas.',
    
    'step_8_title': 'Limpieza del Terreno',
    'step_8_description': 'Después de la cosecha, el terreno debe limpiarse para prepararlo para el próximo ciclo de siembra.\n\nLos pasos clave de esta etapa incluyen:\n• Remoción de residuos vegetales: Se eliminan tallos secos, malas hierbas y restos de cultivos anteriores.\n• Preparación del suelo: Se realiza el arado o aireado del suelo para mejorar la retención de humedad y el acceso a nutrientes.',

    // Community Page
    'community_title': 'Comunidad',
    'moon_phases': 'Fases de la Luna',
    'weather_forecast': 'Pronóstico del Tiempo',
    'short_term_forecast': 'Pronóstico a Corto Plazo',
    'seasonal_forecast': 'Pronóstico Estacional',
    'precipitation': 'Precipitación',
    'confidence': 'Confianza',
    'wet': 'Húmedo',
    'normal': 'Normal',
    'dry': 'Seco',
    'last_updated': 'Última Actualización',
    'no_forecast_available': 'No hay pronóstico disponible',
    'cultural_practices': 'Prácticas Culturales',
    'environmental_conservation': 'Conservación Ambiental',
    'community_events': 'Eventos Comunitarios',
    'educational_resources': 'Recursos Educativos',

    // Moon Calendar
    'lunar_calendar': 'Calendario Lunar',
    'welcome_lunar': 'Bienvenido a la Fase Lunar',
    'lunar_description': 'Este calendario muestra las fases de la luna para cada día del mes. Haz clic en cualquier fase lunar para ver sus detalles, como la fecha, el nombre de la fase, la luminosidad y la próxima luna llena.',
    'understood': 'Entendido',
    'date': 'Fecha',
    'phase': 'Fase',
    'luminosity': 'Luminosidad',
    'next_full_moon': 'Próxima Luna Llena',
    'waning_crescent': 'Menguante Iluminante',

    // Audio and Error Messages
    'loading': 'Cargando...',
    'stop_audio': 'Detener audio',
    'audio_error': 'Error al reproducir el audio. Por favor, intente de nuevo.',
    'image_error': 'Error: Imagen no encontrada',

    // Settings Page
    'select_language': 'Selecciona el Idioma',
    'language': 'Idioma',
  },
  'yua': {
    // Landing Page
    'preserving': 'K kanáantik',
    'heritage': 'U k\'aaba\'il',
    'yucatan': 'Yucatán',
    'maps': 'Péets\'ilo\'ob',
    'agricultural_cycles': 'U súutukil kool',
    'community': 'Kaaj',
    'reports': 'Tsoolilo\'ob',
    'help': 'Áantaj',
    'settings': 'Nu\'ukulo\'ob',

    // Reports Page
    'reports_title': 'Tsoolilo\'ob',
    'new_report': 'Meent jump\'éel túumben tsool',
    'report_name': 'U k\'aaba\' le tsool',
    'report_name_hint': 'Je\'el bix: U mejenk\'aak\'il ixi\'im, Talamil ch\'ul ha\'',
    'report_name_error': 'Ts\'o\'ok a ts\'íibtik u k\'aaba\' le tsool',
    'category': 'U jejeláasil',
    'description': 'U tsoolil le talamilo\'',
    'description_hint': 'Tsolte\' le talamilo\' tu beel...',
    'description_error': 'Ts\'o\'ok a ts\'íibtik ba\'ax ku yúuchul',
    'location': 'Tu\'ux ku yúuchul (Ma\' k\'a\'ana\'ani\')',
    'location_hint': 'Je\'el bix: Xaman kool, Kanjalab 3',
    'crop_yield': 'U yich le paak\'alo\' (Ma\' k\'a\'ana\'ani\')',
    'crop_yield_hint': 'Je\'el bix: Ka\'ap\'éel tóonelaadas ti\' jump\'éel ektaarea',
    'incident_date': 'U k\'iinil úuchik',
    'submit': 'Túuxt le tsool',
    'success': 'Ts\'o\'ok u k\'amik le tsool',
    'error': 'Ma\' béeychaj u túuxta\'al le tsool',
    'try_again': 'Ka\'a tumtej',

    // Agricultural Cycles Page
    'agricultural_cycles_title': 'U súutukil kool',
    'welcome_cycles': 'Ki\'ki\' k\'iin ti\' u súutukil kool',
    'cycles_description': 'Pech\'t\'an le xóot\'o\'ob utia\'al a kanik ya\'ab ba\'al yo\'osal u jejeláasil meyaj kool.',
    'continue': 'Ts\'o\'okol',
    'example_image': 'U ye\'esajil',
    'stage_description': 'U tsoolil le meyaja\':',
    'play_audio': 'Cha\'ant t\'aan',

    // Agricultural Cycle Steps
    'step_1_title': 'U yéeyal kool wa páarselail k\'áax',
    'step_1_description': 'U t\'oxol kool wa páarselail k\'áax leti\' u yáax meyajil ti\' u súutukil kool. Ti\' le meyaja\', u jo\'olpóopilo\'ob kaaj, je\'el bix nukuch máako\'ob wa u múuch\'kabil kaaj, ku t\'oxiko\'ob u jaatsilo\'ob k\'áax ti\' jejeláas baatsilo\'ob wa kolnáalo\'ob. Le meyaja\' ku beeta\'al je\'el bix suuka\'an, yéetel u ka\'anal óolal kaaj.',
    
    'step_2_title': 'U ch\'akil k\'áax (U ch\'akil che\'ob)',
    'step_2_description': 'Ti\' le meyaja\' ku líik\'sa\'al u yich lu\'um yéetel u ch\'a\'akal che\'ob. Leti\' jump\'éel suuka\'anil meyaj k\'a\'abéet u yojéelta\'al bix u beeta\'al utia\'al ma\' u k\'askúunta\'al ya\'ab k\'áax.',
    
    'step_3_title': 'U tóoka\'al k\'áax',
    'step_3_description': 'U tóoka\'al k\'áax leti\' jump\'éel úuchben meyaj k\'a\'abéet u yojéelta\'al bix u beeta\'al. Ti\' le meyaja\', le kolnáalo\'obo\' ku tóokiko\'ob u tikin che\'ilo\'ob yéetel u paakilo\'ob, je\'el bix u ka\'ansajo\'ob le úuchben máako\'obo\' utia\'al ma\' u yúuchul k\'aas yéetel u ma\'alobkíinsa\'al u yich lu\'um.',
    
    'step_4_title': 'U pa\'ak\'al ixi\'im',
    'step_4_description': 'U pa\'ak\'al ixi\'im leti\' u káajbal kool ichil u súutukil kolnáalil. Ti\' le meyaja\', le kolnáalo\'obo\' ku yéeyiko\'ob le ma\'alob ixi\'imo\' yéetel ku pa\'ak\'iko\'ob ichil le ma\'alobkíinsa\'an lu\'umo\'.\n\nLe ba\'alo\'ob jach k\'a\'ana\'an ti\' le meyaja\':\n• U yéeya\'al ixi\'im: Ku yéeya\'al le ixi\'im ma\'alob ti\' le k\'iino\' yéetel le lu\'umo\'.\n• U ma\'alobkíinsa\'al lu\'um: Ku póok lu\'um yéetel ku kanáanta\'al u ma\'alobtal utia\'al u jóok\'ol ixi\'im.\n• U nu\'ukbesajil pa\'ak\'al: Je\'el bix u beeta\'al ichil le kaajo\', je\'el u páajtal u beeta\'al je\'el bix úuchben meyaj wa túumben meyaj.',
    
    'step_5_title': 'U ch\'íijil paak\'áal',
    'step_5_description': 'U ch\'íijil paak\'áal leti\' jump\'éel k\'a\'ana\'an meyaj k\'a\'abéet u kanáanta\'al yéetel u yila\'al sáansamal. Ti\' le k\'iino\'oba\', le kolnáalo\'obo\' ku kanáantiko\'ob yéetel ku ts\'áako\'ob ki\'il ti\' le paak\'áalo\'obo\' utia\'al u ma\'alobtal u ch\'íijilo\'ob.\n\nLe ba\'alo\'ob k\'a\'ana\'an u beeta\'al ti\' le meyaja\':\n• U ts\'áabal ja\': U kanáanta\'al u ch\'upul le lu\'umo\'.\n• U xu\'ulsa\'al k\'aak\'as xíiw: U luk\'sa\'al le xíiwo\'ob ma\' k\'a\'ana\'ano\'obo\'.\n• U yila\'al mejen k\'aak\'as: U kanáanta\'al le paak\'áalo\'ob ti\' le ba\'alo\'ob je\'el u k\'askúuntiko\'obo\'.',
    
    'step_6_title': 'U lóol paak\'áal',
    'step_6_description': 'U lóol paak\'áal leti\' jump\'éel jach k\'a\'ana\'an meyaj ichil u súutukil kolnáalil, tu\'ux le paak\'áalo\'obo\' ku meentiko\'ob u loolo\'ob, le je\'el u súutulo\'ob ti\' u yicho\'ob wa u yixi\'imo\'ob.\n\nTi\' le meyaja\':\n• Le paak\'áalo\'obo\' k\'a\'abéet u yantal ti\'ob ma\'alob sáasil yéetel chokoj.\n• K\'a\'ana\'an u ts\'áabal ja\' ti\'ob chen ba\'ale\' ma\' ya\'ab.\n• K\'a\'abéet u kanáanta\'al u loolo\'ob ti\' mejen k\'aak\'as yéetel k\'aas k\'iin.',
    
    'step_7_title': 'U jóok\'sa\'al u yich',
    'step_7_description': 'U jóok\'sa\'al u yich leti\' juntúul ti\' le asab k\'a\'ana\'an meyajo\'ob ichil u súutukil kolnáalil. Ti\' le meyaja\', le kolnáalo\'obo\' ku much\'iko\'ob le táan u k\'aank\'anchajal paak\'áalo\'obo\' yéetel ku kanáantiko\'ob u ma\'alobil.\n\nLe ba\'alo\'ob jach k\'a\'ana\'an ti\' le meyaja\':\n• Bix u beeta\'al: Je\'el bix ba\'ax ku pa\'ak\'alo\', je\'el u páajtal u beeta\'al yéetel k\'ab wa yéetel nu\'ukulo\'ob.\n• U k\'iinil u beeta\'al: Ku jets\'a\'al je\'el bix u k\'aank\'anchajal le paak\'áalo\' yéetel bix yanik le k\'iino\'.',
    
    'step_8_title': 'U p\'o\'ol lu\'um',
    'step_8_description': 'Ken ts\'o\'okok u jóok\'sa\'al u yich, k\'a\'abéet u p\'o\'ol le lu\'umo\' utia\'al u ma\'alobkíinsa\'al utia\'al u ka\'a pa\'ak\'al.\n\nLe ba\'alo\'ob k\'a\'ana\'an u beeta\'al ti\' le meyaja\':\n• U luk\'sa\'al u xíiwil: Ku luk\'sa\'al u k\'a\'ax che\'ilo\'ob, k\'aak\'as xíiwo\'ob yéetel u xíiwil le ts\'o\'ok u jóok\'sa\'al u yicho\'.\n• U ma\'alobkíinsa\'al lu\'um: Ku wa\'ak\'al wa ku póok\'ol le lu\'umo\' utia\'al u ma\'alobtal u ch\'upul yéetel u yantal u ki\'il.',

    // Community Page
    'community_title': 'Kaaj',
    'moon_phases': 'U jaatsilo\'ob Uj',
    'weather_forecast': 'U yoochel k\'iin',
    'short_term_forecast': 'U yoochel k\'iin ti\' ma\' xaan',
    'seasonal_forecast': 'U yoochel k\'iin ti\' jump\'éel k\'iinilo\'ob',
    'precipitation': 'Cháak',
    'confidence': 'Confianza',
    'wet': 'Ch\'up',
    'normal': 'Normal',
    'dry': 'Tikin',
    'last_updated': 'Última actualización',
    'no_forecast_available': 'Mina\'an pronóstico',
    'cultural_practices': 'Miatsil Meyajo\'ob',
    'environmental_conservation': 'U kanáanta\'al Yóok\'ol Kaab',
    'community_events': 'U múuch\'tambail Kaaj',
    'educational_resources': 'Nu\'ukulo\'ob Xook',

    // Moon Calendar
    'lunar_calendar': 'U Xookil Uj',
    'welcome_lunar': 'Ki\'imak óolal ti\' U Xookil Uj',
    'lunar_description': 'Le xookila\' ku ye\'esik u jaatsilo\'ob uj ti\' lalaj k\'iin ichil le winala\'. Pech ti\' je\'el máaxake\' jaats uj utia\'al a wilik u ju\'unil, u k\'aaba\' le jaats, u sáasil yéetel u talamil uj ku taale\'.',
    'understood': 'Ma\'alob',
    'date': 'K\'iin',
    'phase': 'U jaatsil',
    'luminosity': 'U sáasil',
    'next_full_moon': 'U k\'iinil u chúupul uj ku taale\'',
    'waning_crescent': 'U yáax jaatsil Uj',

    // Audio and Error Messages
    'loading': 'Táan u káajal...',
    'stop_audio': 'Ch\'éen t\'aan',
    'audio_error': 'Ma\' béeychaj u cha\'anta\'al t\'aan. Chan tumtej tuka\'atéen.',
    'image_error': 'Ma\' béeychaj u ye\'esa\'al le oochela\'',

    // Settings Page
    'select_language': 'Yéey t\'aan',
    'language': 'T\'aan',
  },
}; 