import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/localization_service.dart';
import 'widgets/scroll_down_indicator.dart';

class AgriculturalCyclesPage extends StatefulWidget {
  const AgriculturalCyclesPage({super.key});

  @override
  State<AgriculturalCyclesPage> createState() => _AgriculturalCyclesPageState();
}

class _AgriculturalCyclesPageState extends State<AgriculturalCyclesPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && _showArrow) {
      setState(() => _showArrow = false);
    } else if (_scrollController.offset <= 10 && !_showArrow) {
      setState(() => _showArrow = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    String t(String key) => localization.translate(key);
    final stepsData = [
      {'emoji': '🌱', 'title_key': 'step_1_title', 'route': '/cycle_step_1'},
      {'emoji': '🌾', 'title_key': 'step_2_title', 'route': '/cycle_step_2'},
      {'emoji': '💧', 'title_key': 'step_3_title', 'route': '/cycle_step_3'},
      {'emoji': '☀️', 'title_key': 'step_4_title', 'route': '/cycle_step_4'},
      {'emoji': '🌽', 'title_key': 'step_5_title', 'route': '/cycle_step_5'},
      {'emoji': '🔄', 'title_key': 'step_6_title', 'route': '/cycle_step_6'},
      {'emoji': '🛖', 'title_key': 'step_7_title', 'route': '/cycle_step_7'},
      {'emoji': '🔥', 'title_key': 'step_8_title', 'route': '/cycle_step_8'},
    ];
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: const Color(0xFFA8D5BA),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFA8D5BA),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 18),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFeafaf1),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFA8D5BA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Icons.agriculture, size: 48, color: Color(0xFF388E3C)),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              t('agricultural_cycles_title'),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      t('tap_each_step_to_learn_more'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        color: Color(0xFF388E3C),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Text(
                      t('based_on_traditional_mayan_milpa'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8D6E63),
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(stepsData.length, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, stepsData[i]['route']!),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stepsData[i]['emoji']!, style: const TextStyle(fontSize: 36)),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Text(
                                  '${t('step_prefix')} ${i + 1}: ${t(stepsData[i]['title_key']!)}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.brown, size: 22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
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