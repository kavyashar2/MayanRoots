import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<_LanguageDropdownItem> _languages = [
    _LanguageDropdownItem('Español', '🇪🇸', 'es'),
    _LanguageDropdownItem('Maya', '🇲🇽', 'yua'),
    _LanguageDropdownItem('English', '🇬🇧', 'en'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localization, child) {
        final currentLangCode = localization.currentLanguage;
        _LanguageDropdownItem? selectedLanguageItem = _languages.firstWhere(
          (lang) => lang.code == currentLangCode,
          orElse: () => _languages.first,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(localization.translate('settings_page_title')),
            backgroundColor: const Color(0xFFA8D5BA),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.translate('select_language'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<_LanguageDropdownItem>(
                      value: selectedLanguageItem,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black, size: 32),
                      isExpanded: true,
                      style: const TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'Montserrat'),
                      items: _languages.map((item) {
                        return DropdownMenuItem<_LanguageDropdownItem>(
                          value: item,
                          child: Row(
                            children: [
                              Text(item.flag, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Text(item.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          localization.setLanguage(newValue.code);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // ... add more settings here if needed ...
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageDropdownItem {
  final String name;
  final String flag;
  final String code;
  const _LanguageDropdownItem(this.name, this.flag, this.code);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LanguageDropdownItem &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
} 