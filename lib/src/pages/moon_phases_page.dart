import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import 'package:intl/intl.dart';
import '../widgets/scroll_down_indicator.dart';

class MoonPhasesPage extends StatefulWidget {
  const MoonPhasesPage({super.key});

  @override
  State<MoonPhasesPage> createState() => _MoonPhasesPageState();
}

class _MoonPhasesPageState extends State<MoonPhasesPage> {
  DateTime _selectedDate = DateTime.now();
  int? _selectedDay;
  final _mintGreen = const Color(0xFF98E5BE);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  String _formatDate(LocalizationService localization, DateTime date) {
    try {
      return DateFormat('d MMMM y', localization.currentLanguage).format(date);
    } catch (e) {
      return DateFormat('d MMMM y', 'es').format(date);
    }
  }

  String _getWeekdayName(int weekday, bool short) {
    Map<int, String> longDays = {
      1: 'LUNES',
      2: 'MARTES',
      3: 'MIÉRCOLES',
      4: 'JUEVES',
      5: 'VIERNES',
      6: 'SÁBADO',
      7: 'DOMINGO',
    };
    Map<int, String> shortDays = {
      1: 'LUN',
      2: 'MAR',
      3: 'MIE',
      4: 'JUE',
      5: 'VIE',
      6: 'SÁB',
      7: 'DOM',
    };
    return short ? shortDays[weekday]! : longDays[weekday]!;
  }

  Widget _buildWeekView() {
    // Get the start of the current week (Monday)
    DateTime monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          DateTime day = monday.add(Duration(days: index));
          bool isSelected = day.day == _selectedDate.day;
          return Column(
            children: [
              Text(
                _getWeekdayName(day.weekday, true),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  decoration: isSelected ? TextDecoration.underline : null,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCalendar() {
    // Get the first day of the current month
    final DateTime firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    // Get the last day of the current month
    final DateTime lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    // Calculate how many days from previous month to show
    final int daysFromPreviousMonth = firstDayOfMonth.weekday - 1;
    // Get the last day of previous month
    final DateTime lastDayOfPreviousMonth = DateTime(_selectedDate.year, _selectedDate.month, 0);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM y').format(_selectedDate),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Weekday headers
          Row(
            children: List.generate(7, (index) {
              return Expanded(
                child: Center(
                  child: Text(
                    _getWeekdayName(index + 1, true),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              late DateTime currentDate;
              bool isCurrentMonth = true;
              
              // Calculate the date for this grid position
              if (index < daysFromPreviousMonth) {
                // Previous month days
                currentDate = lastDayOfPreviousMonth.subtract(
                  Duration(days: daysFromPreviousMonth - index - 1)
                );
                isCurrentMonth = false;
              } else if (index < daysFromPreviousMonth + lastDayOfMonth.day) {
                // Current month days
                currentDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  index - daysFromPreviousMonth + 1,
                );
              } else {
                // Next month days
                currentDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                  index - daysFromPreviousMonth - lastDayOfMonth.day + 1,
                );
                isCurrentMonth = false;
              }

              final bool isSelected = currentDate.year == _selectedDate.year &&
                                    currentDate.month == _selectedDate.month &&
                                    currentDate.day == _selectedDate.day;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = currentDate;
                  });
                },
                child: Container(
                  decoration: isSelected ? BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    shape: BoxShape.circle,
                  ) : null,
                  child: Center(
                    child: Text(
                      '${currentDate.day}',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentMonth ? Colors.black : Colors.black38,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    final phase = _getMoonPhase(_selectedDate.day);
    final phaseName = _getMoonPhaseName(phase);
    final luminosity = _calculateLuminosity(phase);
    // Optionally, you can add a more descriptive text for each phase
    final phaseDescription = 'Observa la fase lunar actual y su luminosidad.';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🌙', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            const Text('Fases de la Luna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        backgroundColor: _mintGreen,
        elevation: 0,
      ),
      backgroundColor: _mintGreen,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    phase,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    phaseName,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    phaseDescription,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: Color(0xFFF6E7C1),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Fecha: ${_formatDate(localization, _selectedDate)}', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('Fase: $phaseName', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('Luminosidad: $luminosity%', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('Próxima Luna Llena: ${_formatDate(localization, _calculateNextFullMoon(_selectedDate))}', style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildCalendar(),
                const SizedBox(height: 32),
              ],
            ),
          ),
          ScrollDownIndicator(controller: _scrollController),
        ],
      ),
    );
  }

  String _getMoonPhase(int day) {
    int daysSinceNewMoon = day % 29;
    if (daysSinceNewMoon == 0) return "🌑";
    if (daysSinceNewMoon < 7) return "🌒";
    if (daysSinceNewMoon == 7) return "🌓";
    if (daysSinceNewMoon < 14) return "🌔";
    if (daysSinceNewMoon == 14) return "🌕";
    if (daysSinceNewMoon < 21) return "🌖";
    if (daysSinceNewMoon == 21) return "🌗";
    return "🌘";
  }

  String _getMoonPhaseName(String phaseEmoji) {
    switch (phaseEmoji) {
      case "🌑":
        return "LUNA NUEVA";
      case "🌒":
        return "LUNA CRECIENTE";
      case "🌓":
        return "CUARTO CRECIENTE";
      case "🌔":
        return "GIBOSA CRECIENTE";
      case "🌕":
        return "LUNA LLENA";
      case "🌖":
        return "GIBOSA MENGUANTE";
      case "🌗":
        return "CUARTO MENGUANTE";
      case "🌘":
        return "LUNA MENGUANTE";
      default:
        return "DESCONOCIDA";
    }
  }

  double _calculateLuminosity(String phaseEmoji) {
    switch (phaseEmoji) {
      case "🌑":
        return 0.0;
      case "🌒":
        return 25.0;
      case "🌓":
        return 50.0;
      case "🌔":
        return 75.0;
      case "🌕":
        return 100.0;
      case "🌖":
        return 75.0;
      case "🌗":
        return 50.0;
      case "🌘":
        return 25.0;
      default:
        return 0.0;
    }
  }

  DateTime _calculateNextFullMoon(DateTime date) {
    int daysSinceNewMoon = date.difference(DateTime(2025, 1, 1)).inDays % 29;
    int daysToNextFullMoon = (14 - daysSinceNewMoon) % 29;
    return date.add(Duration(days: daysToNextFullMoon));
  }

  String _getPhaseTitle(String phase, LocalizationService localization) {
    // Implementation of _getPhaseTitle method
    return ''; // Placeholder return, actual implementation needed
  }

  String _getPhaseDescription(String phase, LocalizationService localization) {
    // Implementation of _getPhaseDescription method
    return ''; // Placeholder return, actual implementation needed
  }

  String _getMoonImage(String phase) {
    // Implementation of _getMoonImage method
    return ''; // Placeholder return, actual implementation needed
  }
} 