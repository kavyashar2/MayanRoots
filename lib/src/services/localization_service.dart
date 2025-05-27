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
    
    final translations = _translations[_currentLanguage];
    if (translations == null) {
      _log('❌ Error: No translations found for language: $_currentLanguage');
      return key;
    }
    
    final translation = translations[key] ?? key;
    _log('Translating key: $key to: $translation (language: $_currentLanguage)');
    return translation;
  }
}

// Define translation map with explicit type
final Map<String, Map<String, String>> _translations = {
  'es': {
    'preserving': 'Preservando el',
    'heritage': 'Patrimonio de',
    'yucatan': 'Yucatán',
    'maps': 'Mapas',
    'agricultural_cycles': 'Ciclos Agrícolas',
    'community': 'Comunidad',
    'community_title': 'Comunidad',
    'reports': 'Reportes',
    'help': 'Ayuda',
    'settings': 'Configuración',
    'settings_page_title': 'Configuración',
    'forecast_and_history': 'Pronóstico y Datos Históricos',

    // Reports Page
    'reports_title': 'Reportes',
    'new_report': 'Nuevo Reporte',
    'report_name': 'Nombre del reporte',
    'report_name_hint': 'Ingrese un nombre para su reporte',
    'report_name_error': 'Por favor ingrese un nombre para el reporte',
    'description': 'Descripción',
    'description_hint': 'Describa lo que está reportando',
    'description_error': 'Por favor ingrese una descripción',
    'location': 'Ubicación',
    'location_hint': 'Ingrese la ubicación del reporte',
    'crop_yield': 'Rendimiento del cultivo',
    'crop_yield_hint': 'Ingrese el rendimiento (opcional)',
    'email_optional': 'Correo electrónico (Opcional)',
    'email_hint': 'Ejemplo: usuario@email.com',
    'incident_date': 'Fecha del incidente',
    'submit_report': 'Enviar Reporte',
    'cancel': 'Cancelar',
    'photo': 'Foto',
    'take_photo': 'Tomar Foto',
    'select_photo': 'Seleccionar Foto',
    'success': 'Reporte enviado con éxito',
    'error': 'Error al enviar el reporte',
    'try_again': 'Intentar de nuevo',
    'select_language': 'Selecciona el Idioma',
    'language': 'Idioma',
    
    // Agricultural Cycles
    'agricultural_cycles_title': 'Agricultural Cycles',
    'step_prefix': 'Step',
    'welcome_cycles': 'Welcome to the Agricultural Cycles page',
    'cycles_description': 'Tap the numbers to learn more about each step of the agricultural process.',
    'continue': 'Continue',
    'example_image': 'Example Image',
    'stage_description': 'Stage Description:',
    'play_audio': 'Play Audio',
    
    // Step 1
    'step_1_title': 'Selección de Terrenos o Parcelas Forestales',
    'step_1_desc_segment_1': 'La distribución de terrenos o parcelas forestales es el primer paso esencial en el ciclo agrícola. En esta etapa, los líderes de la comunidad, como los ancianos o el consejo comunal, asignan áreas específicas del bosque o terreno a diferentes familias o agricultores. Este proceso se basa en la tradición, el conocimiento local y las necesidades de la comunidad.',
    'step_1_desc_segment_2_prefix': 'La distribución busca asegurar un uso equitativo y sostenible de la tierra,',
    'step_1_desc_segment_2_suffix': 'respetando los límites ecológicos y fomentando la regeneración del bosque en terrenos previamente utilizados.',
    'step_1_desc_segment_3_prefix': 'Este paso también refuerza el tejido social',
    'step_1_desc_segment_3_suffix': 'al involucrar a los miembros de la comunidad en decisiones colaborativas.',
    
    // Step 2
    'step_2_title': 'Desmonte del Terreno (Corte de Vegetación)',
    'step_2_desc_segment_1': 'El desmonte del terreno es el proceso de eliminación de la vegetación para preparar la tierra para la siembra.',
    'step_2_desc_segment_2': 'Esto puede incluir la remoción de árboles, arbustos y maleza que puedan obstruir la producción agrícola.',
    'step_2_desc_segment_3': 'Las técnicas utilizadas varían según la región y los recursos disponibles. En comunidades tradicionales, se emplean herramientas manuales como machetes, mientras que en sistemas agrícolas modernos se pueden usar máquinas pesadas para despejar grandes áreas.',
    'step_2_desc_segment_4': 'Es importante llevar a cabo este proceso de manera responsable, preservando ciertos árboles para mantener la biodiversidad, evitar la erosión del suelo y asegurar la regeneración del ecosistema.',
    'step_2_desc_segment_5': 'Las prácticas sostenibles buscan minimizar el impacto ambiental y garantizar la fertilidad del suelo para los siguientes ciclos de cultivo.',
    
    // Step 3
    'step_3_title': 'Secado al Sol y Quema de Vegetación Cortada',
    'step_3_desc_s1': 'Después del desmonte del terreno, la vegetación cortada se deja secar al sol durante varios días. Este proceso permite que el material vegetal pierda humedad, facilitando su posterior quema de manera controlada.',
    'step_3_desc_s2': 'La quema controlada es una técnica agrícola tradicional utilizada para eliminar los restos vegetales y devolver nutrientes esenciales al suelo. Este proceso libera potasio y otros minerales, mejorando la fertilidad de la tierra para la siguiente cosecha.',
    'step_3_desc_s3': 'Sin embargo, la quema debe realizarse con precaución para evitar incendios incontrolados y proteger la calidad del suelo. Alternativas sostenibles incluyen la incorporación de materia orgánica en el suelo mediante compostaje o el uso de técnicas de conservación agrícola para minimizar la pérdida de nutrientes.',
    
    // Step 4
    'step_4_title': 'Siembra de las Semillas',
    'step_4_desc_s1': 'La siembra de semillas marca el inicio del cultivo en el ciclo agrícola. Durante esta fase, los agricultores seleccionan las mejores semillas y las plantan en el suelo preparado.',
    'step_4_desc_s2': 'Los factores clave en esta etapa incluyen:',
    'step_4_bullet_1_title': 'Selección de semillas:',
    'step_4_bullet_1_text': 'Se eligen variedades adaptadas al clima y tipo de suelo.',
    'step_4_bullet_2_title': 'Preparación del suelo:',
    'step_4_bullet_2_text': 'Se remueve la tierra y se aseguran las condiciones óptimas para la germinación.',
    'step_4_bullet_3_title': 'Técnicas de siembra:',
    'step_4_bullet_3_text': 'Dependiendo de la comunidad, se pueden utilizar métodos tradicionales o técnicas modernas como la siembra directa.',
    'step_4_desc_s3': 'El éxito de esta etapa depende de factores como la disponibilidad de agua, el calendario agrícola y la biodiversidad asegurando una cosecha saludable y sostenible.',
    
    // Step 5
    'step_5_title': 'Mantenimiento y Deshierbe',
    'step_5_desc_s1': 'El mantenimiento y deshierbe son esenciales para el crecimiento saludable de los cultivos. Durante esta fase, los agricultores eliminan las hierbas no deseadas que compiten con los cultivos por agua y nutrientes.',
    'step_5_desc_s2': 'Los pasos clave en esta etapa incluyen:',
    'step_5_bullet_1_title': 'Deshierbe manual:',
    'step_5_bullet_1_text': 'Se utilizan herramientas tradicionales para evitar el uso excesivo de químicos.',
    'step_5_bullet_2_title': 'Control de plagas:',
    'step_5_bullet_2_text': 'Se asegura que los cultivos crezcan sanos y sin interferencias de enfermedades.',
    'step_5_bullet_3_title': 'Mantenimiento del suelo:',
    'step_5_bullet_3_text': 'Se garantiza que retenga la humedad adecuada para el crecimiento óptimo de las plantas.',
    'step_5_desc_s3': 'Esta etapa es crucial para garantizar una cosecha abundante y sostenible, minimizando el impacto negativo en el ecosistema local.',
    
    // Step 6
    'step_6_title': 'Cosecha de los Cultivos',
    'step_6_desc_s1': 'La cosecha es una de las etapas más importantes en el ciclo agrícola. En este proceso, los agricultores recolectan los cultivos maduros asegurándose de preservar la calidad del producto.',
    'step_6_desc_s2': 'Los factores clave en esta etapa incluyen:',
    'step_6_bullet_1_title': 'Método de cosecha:',
    'step_6_bullet_1_text': 'Dependiendo del tipo de cultivo, la recolección puede ser manual o con herramientas y maquinaria especializada.',
    'step_6_bullet_2_title': 'Momento adecuado:',
    'step_6_bullet_2_text': 'Se determina observando la madurez del cultivo, las condiciones climáticas y la demanda del mercado.',
    'step_6_bullet_3_title': 'Procesos post-cosecha:',
    'step_6_bullet_3_text': 'Una vez recolectados, los productos pasan por selección, limpieza y almacenamiento antes de su distribución.',
    'step_6_desc_s3': 'Una cosecha bien planificada garantiza un mejor rendimiento y minimiza las pérdidas, asegurando un proceso agrícola sostenible y eficiente.',
    
    // Step 7
    'step_7_title': 'Limpieza del Terreno',
    'step_7_desc_s1': 'Después de la cosecha, el terreno debe limpiarse para prepararlo para el próximo ciclo de siembra.',
    'step_7_desc_s2': 'Los pasos clave en esta etapa incluyen:',
    'step_7_bullet_1_title': 'Remoción de residuos vegetales:',
    'step_7_bullet_1_text': 'Se eliminan tallos secos, malas hierbas y restos de cultivos anteriores.',
    'step_7_bullet_2_title': 'Preparación del suelo:',
    'step_7_bullet_2_text': 'Se realiza el arado o aireado del suelo para mejorar la retención de humedad y el acceso a nutrientes.',
    'step_7_bullet_3_title': 'Control de plagas y enfermedades:',
    'step_7_bullet_3_text': 'Se implementan prácticas para evitar que plagas y hongos afecten futuras plantaciones.',
    'step_7_desc_s3': 'Mantener el terreno limpio garantiza la fertilidad del suelo y reduce riesgos para la siguiente siembra.',
    
    // Step 8
    'step_8_title': 'Selección de Semillas',
    'step_8_desc_s1': 'Antes de iniciar un nuevo ciclo de siembra, es crucial seleccionar semillas de calidad para garantizar una cosecha óptima.',
    'step_8_desc_s2': 'Los pasos clave en esta etapa incluyen:',
    'step_8_bullet_1_title': 'Selección de semillas sanas y resistentes:',
    'step_8_bullet_1_text': 'Se eligen semillas sin daños, con buen tamaño y color homogéneo.',
    'step_8_bullet_2_title': 'Prueba de viabilidad:',
    'step_8_bullet_2_text': 'Algunas semillas se sumergen en agua para verificar su flotabilidad; las que flotan suelen ser descartadas.',
    'step_8_bullet_3_title': 'Tratamientos previos:',
    'step_8_bullet_3_text': 'Algunas semillas son remojadas en soluciones nutritivas o tratadas con fertilizantes naturales para mejorar su crecimiento.',
    'step_8_desc_s3': 'Una selección adecuada de semillas ayuda a obtener plantas más fuertes y resistentes a enfermedades, asegurando una producción agrícola sostenible.',
    
    // Maps
    'map_item_title_1': 'Tahcabo',
    'map_item_title_2': 'Valladolid',
    'map_item_title_3': 'Chichén Itzá',
    'map_item_title_4': 'Yaxunah',
    'mayan_region_tag': 'Región Maya',
    
    // Weather Forecast
    'weather_forecast': 'Datos Históricos 📊',
    'weather_forecast_title': 'Datos Históricos',
    'forecast_info_title': 'Información del Pronóstico',
    'forecast_info_instruction': 'Seleccione un año para ver los pronósticos',
    'forecast_info_explanation1': 'Los pronósticos muestran la probabilidad de condiciones de temperatura y precipitación.',
    'forecast_info_explanation2': 'Los datos se actualizan mensualmente cuando están disponibles.',
    'forecast_info_q_missing_months': '¿Por qué faltan algunos meses?',
    'forecast_info_a_missing_months': 'No todos los meses tienen datos de pronóstico disponibles. Solo mostramos los meses con datos confiables.',
    'understood': 'Entendido',
    'select_year': 'Seleccionar Año para ver datos históricos',
    'probability': 'probabilidad',
    'precipitation': 'precipitación',
    'recent_rainfall_measurement': 'Medición reciente de lluvia',
    'data_source': 'Fuente de datos:',
    'temp_below_normal': 'Temperatura por debajo de lo normal',
    'temp_above_normal': 'Temperatura por encima de lo normal',
    'warmer': 'más cálido',
    'normal': 'normal',
    'colder': 'más frío',
    'probability_warmer': 'Probabilidad de temperatura más cálida:',
    'probability_description': 'Los pronósticos se basan en modelos climáticos y pueden cambiar.',
    'probability_colder_end': 'Continúe consultando para actualizaciones.',
    'no_forecast': 'Sin pronóstico disponible',
    'why_missing_months': '¿Por qué faltan datos?',
    'missing_months_explanation': 'Los datos para este mes aún no están disponibles o no son confiables.',
    'updated_data': 'Datos actualizados:',
    'location': 'Ubicación:',
    'forecast_note': 'Nota sobre los datos',
    'how_to_use': 'Cómo usar',
    'forecast_usage': 'Uso de los datos históricos',
    'how_this_helps': 'Cómo ayuda esto',
    'forecast_benefits': 'Beneficios de los datos históricos',
    'ask_advisor': 'Consultar a un asesor',
    'data_source_note': 'Fuente de datos',
    
    // Lunar Cycle
    'lunar_cycle_title': 'Ciclo Lunar',
    'select_month': 'Seleccione Mes',
    'select_year': 'Seleccione Año',
    'full_moon': 'Luna Llena',
    'new_moon': 'Luna Nueva',
    'first_quarter': 'Cuarto Creciente',
    'last_quarter': 'Cuarto Menguante',
    'january': 'Enero',
    'february': 'Febrero',
    'march': 'Marzo',
    'april': 'Abril',
    'may': 'Mayo',
    'june': 'Junio',
    'july': 'Julio',
    'august': 'Agosto',
    'september': 'Septiembre',
    'october': 'Octubre',
    'november': 'Noviembre',
    'december': 'Diciembre',
    'moon_phase': 'Fase Lunar',
    'mayan_date': 'Fecha Maya',
    'gregorian_date': 'Fecha Gregoriana',
    'traditional_activity': 'Actividad Tradicional',
    'planting_recommendation': 'Recomendación para Siembra',
    'favorable': 'Favorable',
    'unfavorable': 'Desfavorable',
    'neutral': 'Neutral',

    // Community Page
    'community_title': 'Comunidad',
    'moon_phases': 'Fases Lunares 🌙',
    'weather_forecast': 'Datos Históricos 📊',
  },
  'yua': {
    'preserving': 'K kanáantik',
    'heritage': 'U k\'aaba\'il',
    'yucatan': 'Yucatán',
    'maps': 'Péets\'ilo\'ob',
    'agricultural_cycles': 'U súutukil kool',
    'community': 'Kaaj',
    'community_title': 'Kaaj',
    'reports': 'Tsoolilo\'ob',
    'help': 'Áantaj',
    'settings': 'Nu\'ukulo\'ob',
    'settings_page_title': 'Nu\'ukulo\'ob',
    'forecast_and_history': 'Ts\'ook K\'áat yéetel K\'iinil K\'ajóolt\'aan',

    // Weather Forecast
    'weather_forecast': 'Xookilo\'ob k\'iin uuchil',
    'weather_forecast_title': 'Xookilo\'ob k\'iin uuchil',
    'forecast_info_title': 'U tsikbalil u tsolol le k\'iino\'',
    'forecast_info_instruction': 'Yéey jump\'éel ja\'ab uti\'al a wilik u tsolil',
    'forecast_info_explanation1': 'Le tsololo\'oba\' ku ye\'esiko\'ob bix u páajtal u beetik le chokoj yéetel ja\'il.',
    'forecast_info_explanation2': 'Le xookila\' ku túumbenkúunsa\'al sáansamal kéen yantak.',
    'forecast_info_q_missing_months': '¿Ba\'axten mina\'an jayp\'éel winalo\'ob?',
    'forecast_info_a_missing_months': 'Ma\' tuláakal winalo\'ob yaan u tsolol. Chéen k-ye\'esik le yaan u jaajil xookilo\'.',
    'understood': 'Ts\'o\'ok in na\'atik',
    'select_year': 'Yéey ja\'ab uti\'al a wilik xookilo\'ob k\'iin uuchil',
    'probability': 'bix u páajtal',
    'precipitation': 'ja\'il',
    'recent_rainfall_measurement': 'U p\'iisil le ts\'o\'ok ja\'o\'',
    'data_source': 'Tu\'ux ku tal xookil:',
    'temp_below_normal': 'Chokojil yáanal ti\' suuka\'an',
    'temp_above_normal': 'Chokojil ka\'anal ti\' suuka\'an',
    'warmer': 'asab chokoj',
    'normal': 'suuka\'an',
    'colder': 'asab ke\'el',
    'probability_warmer': 'Bix u páajtal u beetik asab chokoj:',
    'probability_description': 'Le tsololo\'oba\' ku tal tu xookil le k\'iino\' yéetel je\'el u k\'éexelo\'.',
    'probability_colder_end': 'Láak\' k\'iin a wilik tu ka\'aten.',
    'no_forecast': 'Mina\'an tsolol',
    'why_missing_months': '¿Ba\'axten mina\'an xookil?',
    'missing_months_explanation': 'Le xookil ti\' le winala\' ma\' ts\'o\'ok u k\'uchul wa ma\' jaajo\'.',
    'updated_data': 'Xookil túumbenkúunsa\'an:',
    'location': 'Tu\'ux:',
    'forecast_note': 'Ts\'íibil ti\' le xookilo\'',
    'how_to_use': 'Bix u k\'a\'abéetkunsa\'al',
    'forecast_usage': 'U meyajta\'al le xookilo\'ob k\'iin uuchilo\'',
    'how_this_helps': 'Bix ku yáantik le je\'ela\'',
    'forecast_benefits': 'U yutsil le xookilo\'ob k\'iin uuchilo\'',
    'ask_advisor': 'K\'áat ti\' máax ku táakpajal',
    'data_source_note': 'Tu\'ux ku tal le xookilo\'',

    // Lunar Cycle
    'lunar_cycle_title': 'U xíimbal Uj',
    'select_month': 'Yéey Winal',
    'select_year': 'Yéey Ja\'ab',
    'full_moon': 'Chuup Uj',
    'new_moon': 'Tumben Uj',
    'first_quarter': 'Táan u líik\'il Uj',
    'last_quarter': 'Táan u yéemel Uj',
    'january': 'Enero',
    'february': 'Febrero',
    'march': 'Marzo',
    'april': 'Abril',
    'may': 'Mayo',
    'june': 'Junio',
    'july': 'Julio',
    'august': 'Agosto',
    'september': 'Septiembre',
    'october': 'Octubre',
    'november': 'Noviembre',
    'december': 'Diciembre',
    'moon_phase': 'Bix yanik Uj',
    'mayan_date': 'K\'iin ti\' Maya',
    'gregorian_date': 'K\'iin ti\' Gregoriana',
    'traditional_activity': 'Suuka\'an Meyaj',
    'planting_recommendation': 'No\'ojbesaj ti\' pak\'al',
    'favorable': 'Ma\'alob',
    'unfavorable': 'Ma\' ma\'alobi\'',
    'neutral': 'Chúumuk',

    // Community Page
    'community_title': 'Kaaj',
    'moon_phases': 'U xíimbal Uj 🌙',
    'weather_forecast': 'Xookilo\'ob k\'iin uuchil 📊',
  },
  'en': {
    'preserving': 'Preserving the',
    'heritage': 'Heritage of',
    'yucatan': 'Yucatán',
    'maps': 'Maps',
    'agricultural_cycles': 'Agricultural Cycles',
    'community': 'Community',
    'community_title': 'Community',
    'reports': 'Reports',
    'help': 'Help',
    'settings': 'Settings',
    'settings_page_title': 'Settings',
    'forecast_and_history': 'Forecast and Historical Data',

    // Reports Page
    'reports_title': 'Reports',
    'new_report': 'New Report',
    'report_name': 'Report Name',
    'report_name_hint': 'Enter a name for your report',
    'report_name_error': 'Please enter a report name',
    'description': 'Description',
    'description_hint': 'Describe what you are reporting',
    'description_error': 'Please enter a description',
    'location': 'Location',
    'location_hint': 'Enter the location of the report',
    'crop_yield': 'Crop Yield',
    'crop_yield_hint': 'Enter yield (optional)',
    'email_optional': 'Email (Optional)',
    'email_hint': 'Example: user@email.com',
    'incident_date': 'Incident Date',
    'submit_report': 'Submit Report',
    'cancel': 'Cancel',
    'photo': 'Photo',
    'take_photo': 'Take Photo',
    'select_photo': 'Select Photo',
    'success': 'Report submitted successfully',
    'error': 'Error submitting report',
    'try_again': 'Try Again',
    'select_language': 'Select Language',
    'language': 'Language',
    
    // Agricultural Cycles
    'agricultural_cycles_title': 'Agricultural Cycles',
    'step_prefix': 'Step',
    'welcome_cycles': 'Welcome to the Agricultural Cycles page',
    'cycles_description': 'Tap the numbers to learn more about each step of the agricultural process.',
    'continue': 'Continue',
    'example_image': 'Example Image',
    'stage_description': 'Stage Description:',
    'play_audio': 'Play Audio',
    
    // Step 1
    'step_1_title': 'Selection of Land or Forest Plots',
    'step_1_desc_segment_1': 'The distribution of land or forest plots is the first essential step in the agricultural cycle. In this stage, community leaders, such as elders or the communal council, assign specific areas of the forest or land to different families or farmers. This process is based on tradition, local knowledge, and the needs of the community.',
    'step_1_desc_segment_2_prefix': 'The distribution seeks to ensure equitable and sustainable use of the land,',
    'step_1_desc_segment_2_suffix': 'respecting ecological limits and promoting forest regeneration on previously used lands.',
    'step_1_desc_segment_3_prefix': 'This step also reinforces the social fabric',
    'step_1_desc_segment_3_suffix': 'by involving community members in collaborative decisions.',
    
    // Step 2
    'step_2_title': 'Land Clearing (Vegetation Cutting)',
    'step_2_desc_segment_1': 'Land clearing is the process of removing vegetation to prepare the soil for planting.',
    'step_2_desc_segment_2': 'This may include removing trees, shrubs, and weeds that could obstruct agricultural production.',
    'step_2_desc_segment_3': 'The techniques used vary according to the region and available resources. In traditional communities, manual tools such as machetes are used, while in modern agricultural systems, heavy machinery can be used to clear large areas.',
    'step_2_desc_segment_4': 'It is important to carry out this process responsibly, preserving certain trees to maintain biodiversity, prevent soil erosion, and ensure ecosystem regeneration.',
    'step_2_desc_segment_5': 'Sustainable practices seek to minimize environmental impact and guarantee soil fertility for subsequent cultivation cycles.',
    
    // Step 3
    'step_3_title': 'Controlled Burning',
    'step_3_desc_s1': 'After clearing the land, the cut vegetation is left to dry in the sun for several days. This process allows the plant material to lose moisture, facilitating its subsequent controlled burning.',
    'step_3_desc_s2': 'Controlled burning is a traditional agricultural technique used to eliminate plant remains and return essential nutrients to the soil. This process releases potassium and other minerals, improving the fertility of the land for the next harvest.',
    'step_3_desc_s3': 'However, burning must be carried out with caution to avoid uncontrolled fires and protect soil quality. Sustainable alternatives include incorporating organic matter into the soil through composting or using agricultural conservation techniques to minimize nutrient loss.',
    
    // Step 4
    'step_4_title': 'Planting the Seeds',
    'step_4_desc_s1': 'Seed planting marks the beginning of cultivation in the agricultural cycle. During this phase, farmers select the best seeds and plant them in the prepared soil.',
    'step_4_desc_s2': 'Key factors in this stage include:',
    'step_4_bullet_1_title': 'Seed selection:',
    'step_4_bullet_1_text': 'Varieties adapted to the climate and soil type are chosen.',
    'step_4_bullet_2_title': 'Soil preparation:',
    'step_4_bullet_2_text': 'The soil is turned over and optimal conditions for germination are ensured.',
    'step_4_bullet_3_title': 'Planting techniques:',
    'step_4_bullet_3_text': 'Depending on the community, traditional methods or modern techniques such as direct seeding can be used.',
    'step_4_desc_s3': 'The success of this stage depends on factors such as water availability, the agricultural calendar, and biodiversity ensuring a healthy and sustainable harvest.',
    
    // Step 5
    'step_5_title': 'Maintenance and Weeding',
    'step_5_desc_s1': 'Maintenance and weeding are essential for the healthy growth of crops. During this phase, farmers remove unwanted weeds that compete with crops for water and nutrients.',
    'step_5_desc_s2': 'Key steps in this stage include:',
    'step_5_bullet_1_title': 'Manual weeding:',
    'step_5_bullet_1_text': 'Traditional tools are used to avoid excessive use of chemicals.',
    'step_5_bullet_2_title': 'Pest control:',
    'step_5_bullet_2_text': 'Ensuring that crops grow healthy and without interference from diseases.',
    'step_5_bullet_3_title': 'Soil maintenance:',
    'step_5_bullet_3_text': 'Ensuring that it retains adequate moisture for optimal plant growth.',
    'step_5_desc_s3': 'This stage is crucial to ensure an abundant and sustainable harvest, minimizing negative impact on the local ecosystem.',
    
    // Step 6
    'step_6_title': 'Harvesting',
    'step_6_desc_s1': 'Harvesting is one of the most important stages in the agricultural cycle. In this process, farmers collect mature crops ensuring the quality of the product is preserved.',
    'step_6_desc_s2': 'Key factors in this stage include:',
    'step_6_bullet_1_title': 'Harvesting method:',
    'step_6_bullet_1_text': 'Depending on the type of crop, collection can be manual or with specialized tools and machinery.',
    'step_6_bullet_2_title': 'Appropriate timing:',
    'step_6_bullet_2_text': 'This is determined by observing crop maturity, climate conditions, and market demand.',
    'step_6_bullet_3_title': 'Post-harvest processes:',
    'step_6_bullet_3_text': 'Once collected, products go through selection, cleaning, and storage before distribution.',
    'step_6_desc_s3': 'A well-planned harvest ensures better yield and minimizes losses, ensuring a sustainable and efficient agricultural process.',
    
    // Step 7
    'step_7_title': 'Land Cleaning',
    'step_7_desc_s1': 'After harvesting, the land must be cleaned to prepare it for the next planting cycle.',
    'step_7_desc_s2': 'Key steps in this stage include:',
    'step_7_bullet_1_title': 'Removal of plant residues:',
    'step_7_bullet_1_text': 'Dry stalks, weeds, and remains of previous crops are eliminated.',
    'step_7_bullet_2_title': 'Soil preparation:',
    'step_7_bullet_2_text': 'Plowing or aerating the soil is performed to improve moisture retention and access to nutrients.',
    'step_7_bullet_3_title': 'Pest and disease control:',
    'step_7_bullet_3_text': 'Practices are implemented to prevent pests and fungi from affecting future plantations.',
    'step_7_desc_s3': 'Keeping the land clean ensures soil fertility and reduces risks for the next planting.',
    
    // Step 8
    'step_8_title': 'Seed Selection',
    'step_8_desc_s1': 'Before starting a new planting cycle, it is crucial to select quality seeds to ensure an optimal harvest.',
    'step_8_desc_s2': 'Key steps in this stage include:',
    'step_8_bullet_1_title': 'Selection of healthy seeds:',
    'step_8_bullet_1_text': 'Seeds without damage, with good size and homogeneous color are chosen.',
    'step_8_bullet_2_title': 'Viability test:',
    'step_8_bullet_2_text': 'Some seeds are submerged in water to verify their buoyancy; those that float are usually discarded.',
    'step_8_bullet_3_title': 'Pre-treatments:',
    'step_8_bullet_3_text': 'Some seeds are soaked in nutrient solutions or treated with natural fertilizers to improve their growth.',
    'step_8_desc_s3': 'Proper seed selection helps to obtain stronger plants that are more resistant to diseases, ensuring sustainable agricultural production.',
    
    // Maps
    'map_item_title_1': 'Tahcabo',
    'map_item_title_2': 'Valladolid',
    'map_item_title_3': 'Chichen Itza',
    'map_item_title_4': 'Yaxunah',
    'mayan_region_tag': 'Mayan Region',
    
    // Weather Forecast
    'weather_forecast': 'Historical Data',
    'weather_forecast_title': 'Historical Data',
    'forecast_info_title': 'Forecast Information',
    'forecast_info_instruction': 'Select a year to view forecasts',
    'forecast_info_explanation1': 'Forecasts show the probability of temperature and precipitation conditions.',
    'forecast_info_explanation2': 'Data is updated monthly when available.',
    'forecast_info_q_missing_months': 'Why are some months missing?',
    'forecast_info_a_missing_months': 'Not all months have forecast data available. We only show months with reliable data.',
    'understood': 'Understood',
    'select_year': 'Select Year to see historical data',
    'probability': 'probability',
    'precipitation': 'precipitation',
    'recent_rainfall_measurement': 'Recent rainfall measurement',
    'data_source': 'Data source:',
    'temp_below_normal': 'Temperature below normal',
    'temp_above_normal': 'Temperature above normal',
    'warmer': 'warmer',
    'normal': 'normal',
    'colder': 'colder',
    'probability_warmer': 'Probability of warmer temperature:',
    'probability_description': 'Forecasts are based on climate models and may change.',
    'probability_colder_end': 'Continue checking for updates.',
    'no_forecast': 'No forecast available',
    'why_missing_months': 'Why is data missing?',
    'missing_months_explanation': 'Data for this month is not yet available or not reliable.',
    'updated_data': 'Updated data:',
    'location': 'Location:',
    'forecast_note': 'Note about the data',
    'how_to_use': 'How to use',
    'forecast_usage': 'Using historical data',
    'how_this_helps': 'How this helps',
    'forecast_benefits': 'Benefits of historical data',
    'ask_advisor': 'Consult an advisor',
    'data_source_note': 'Data source',

    // Lunar Cycle
    'lunar_cycle_title': 'Lunar Cycle',
    'select_month': 'Select Month',
    'select_year': 'Select Year',
    'full_moon': 'Full Moon',
    'new_moon': 'New Moon',
    'first_quarter': 'First Quarter',
    'last_quarter': 'Last Quarter',
    'january': 'January',
    'february': 'February',
    'march': 'March',
    'april': 'April',
    'may': 'May',
    'june': 'June',
    'july': 'July',
    'august': 'August',
    'september': 'September',
    'october': 'October',
    'november': 'November',
    'december': 'December',
    'moon_phase': 'Moon Phase',
    'mayan_date': 'Mayan Date',
    'gregorian_date': 'Gregorian Date',
    'traditional_activity': 'Traditional Activity',
    'planting_recommendation': 'Planting Recommendation',
    'favorable': 'Favorable',
    'unfavorable': 'Unfavorable',
    'neutral': 'Neutral',

    // Community Page
    'community_title': 'Community',
    'moon_phases': 'Lunar Phases 🌙',
    'weather_forecast': 'Historical Data 📊',
  }
}; 