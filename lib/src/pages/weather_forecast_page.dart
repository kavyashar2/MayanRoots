import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';
import '../services/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:percent_indicator/percent_indicator.dart';

class YearlyForecastPage extends StatefulWidget {
  final int year;
  const YearlyForecastPage({Key? key, required this.year}) : super(key: key);

  @override
  State<YearlyForecastPage> createState() => _YearlyForecastPageState();
}

class _YearlyForecastPageState extends State<YearlyForecastPage> {
  late Future<List<Map<String, dynamic>>> _monthlyForecastsFuture;
  late Future<Map<String, dynamic>> _currentWeatherFuture;
  bool _monthlyInit = false;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    setState(() {
      _monthlyInit = false;
    });
    try {
      final weatherService = await WeatherService.init();
      setState(() {
        _monthlyForecastsFuture = weatherService.getMonthlyTemperatureForecasts();
        _currentWeatherFuture = weatherService.getCurrentWeather();
        _monthlyInit = true;
      });
    } catch (e, stack) {
      setState(() {
        _monthlyInit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localization, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.year} ${localization.translate('weather_forecast_title')}'),
            backgroundColor: const Color(0xFFA8D5BA),
          ),
          body: _buildBody(localization),
        );
      },
    );
  }

  Widget _buildBody(LocalizationService localization) {
    if (!_monthlyInit) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthlyForecasts(localization),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(LocalizationService localization) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _currentWeatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Could not load current weather data.'),
            ),
          );
        }
        final data = snapshot.data!;
        final precipitation = (data['precipitation'] as num?)?.toDouble() ?? 0.0;
        final probability = (data['probability'] as num?)?.toDouble() ?? 1.0;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Precipitation (CHIRPS)',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWeatherInfo(
                      Icons.water_drop,
                      '${precipitation.toStringAsFixed(1)} mm',
                      'Precipitation',
                    ),
                    _buildWeatherInfo(
                      Icons.cloud,
                      '${(probability * 100).toStringAsFixed(0)}%',
                      'Probability',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFA8D5BA), size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyForecasts(LocalizationService localization) {
    if (!_monthlyInit) {
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _monthlyForecastsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        final allForecasts = snapshot.data ?? [];
        // Only show months for the selected year
        final forecasts = allForecasts.where((f) {
          final month = f['forecast_month'] ?? '';
          final dt = DateTime.tryParse(month.length == 7 ? '$month-01' : month);
          return dt != null && dt.year == widget.year;
        }).toList();
        // Group by forecast_month and pick the forecast with the lowest lead_time for each month
        final Map<String, Map<String, dynamic>> monthToBestForecast = {};
        for (final f in forecasts) {
          final month = f['forecast_month'] ?? '';
          if (!monthToBestForecast.containsKey(month) || (f['lead_time'] ?? 99) < (monthToBestForecast[month]?['lead_time'] ?? 99)) {
            monthToBestForecast[month] = f;
          }
        }
        // Prepare all months for the selected year
        final List<DateTime> allMonths = List.generate(12, (i) => DateTime(widget.year, i + 1, 1));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allMonths.length,
              itemBuilder: (context, index) {
                final dt = allMonths[index];
                final monthKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
                final monthLabel = DateFormat('MMMM yyyy').format(dt);
                final forecast = monthToBestForecast[monthKey];
                if (forecast == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      color: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(monthLabel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(localization.translate('no_forecast'), style: TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(
                              localization.translate('why_missing_months'),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                            ),
                            SizedBox(height: 4),
                            Text(
                              localization.translate('missing_months_explanation'),
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final dominant = forecast['dominant_tercile'] ?? 'unknown';
                double? domProb;
                if (dominant == 'above') domProb = forecast['above_probability'];
                else if (dominant == 'normal') domProb = forecast['normal_probability'];
                else if (dominant == 'below') domProb = forecast['below_probability'];
                final prob = domProb != null ? domProb.round().toString() : '?';
                final above = forecast['above_probability']?.toStringAsFixed(0) ?? '?';
                final normal = forecast['normal_probability']?.toStringAsFixed(0) ?? '?';
                final below = forecast['below_probability']?.toStringAsFixed(0) ?? '?';
                final cardColor = _tercileCardColor(dominant);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(monthLabel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Center(
                            child: CircularPercentIndicator(
                              radius: 54.0,
                              lineWidth: 12.0,
                              percent: domProb != null ? (domProb.clamp(0, 100) / 100.0) : 0.0,
                              center: Text(
                                prob != '?' ? "$prob%" : '?',
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _tercileColor(dominant)),
                              ),
                              progressColor: _tercileColor(dominant),
                              backgroundColor: _tercileColor(dominant).withOpacity(0.15),
                              circularStrokeCap: CircularStrokeCap.round,
                              animation: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              _tercileLabel(localization, dominant),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _tercileColor(dominant)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('${localization.translate('warmer')}: $above%   ${localization.translate('normal')}: $normal%   ${localization.translate('colder')}: $below%', style: const TextStyle(fontSize: 15)),
                          const SizedBox(height: 8),
                          _farmerExplanation(localization, dominant, prob, monthLabel),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${localization.translate('data_source')}: IRI NMME, CHIRPS',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Card(
              color: Color(0xFFDAB78D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${localization.translate('forecast_note')}\n\n'
                      '${localization.translate('how_to_use')}\n'
                      '${localization.translate('forecast_usage')}\n\n'
                      '${localization.translate('how_this_helps')}\n'
                      '${localization.translate('forecast_benefits')}\n\n'
                      '${localization.translate('ask_advisor')}\n\n',
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localization.translate('data_source_note'),
                      style: TextStyle(fontSize: 13, color: Colors.black54, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _farmerExplanation(LocalizationService localization, String dominant, String prob, String monthLabel) {
    switch (dominant) {
      case 'above':
        return Text(
          '${localization.translate('probability_warmer')} $prob% ${localization.translate('probability_description')} $monthLabel ${localization.translate('probability_warmer_end')}',
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        );
      case 'below':
        return Text(
          '${localization.translate('probability_warmer')} $prob% ${localization.translate('probability_description')} $monthLabel ${localization.translate('probability_colder_end')}',
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        );
      case 'normal':
        return Text(
          '${localization.translate('probability_warmer')} $prob% ${localization.translate('probability_description')} $monthLabel ${localization.translate('probability_normal_end')}',
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showForecastDetail(BuildContext context, Map<String, dynamic> forecast) {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    final month = forecast['forecast_month'] ?? '';
    final dt = DateTime.tryParse(month.length == 7 ? '$month-01' : month);
    final monthLabel = dt != null ? DateFormat('MMMM yyyy').format(dt) : month;
    final dominant = forecast['dominant_tercile'] ?? 'unknown';
    final prob = forecast['dominant_probability']?.toStringAsFixed(1) ?? '?';
    final lead = forecast['lead_time']?.toString() ?? '?';
    final issued = forecast['issued'] ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(monthLabel),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Most likely: ${_tercileLabel(localization, dominant)} ($prob%)', 
                  style: TextStyle(color: _tercileColor(dominant), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Lead time: $lead month(s)'),
              Text('Issued: $issued'),
              // (Optional) Add advice/explanation here
              if (dominant == 'above')
                Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(localization.translate('probability_warmer_end'), 
                              style: TextStyle(color: Colors.redAccent)),
                ),
              if (dominant == 'below')
                Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(localization.translate('probability_colder_end'), 
                              style: TextStyle(color: Colors.blueAccent)),
                ),
              if (dominant == 'normal')
                Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(localization.translate('probability_normal_end'), 
                              style: TextStyle(color: Colors.green)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localization.translate('understood')),
            ),
          ],
        );
      },
    );
  }

  String _tercileLabel(LocalizationService localization, String tercile) {
    switch (tercile) {
      case 'above':
        return localization.translate('temp_above_normal');
      case 'below':
        return localization.translate('temp_below_normal');
      case 'normal':
        return localization.translate('temp_normal');
      default:
        return localization.translate('temp_unknown');
    }
  }

  Color _tercileColor(String tercile) {
    switch (tercile) {
      case 'above':
        return Colors.redAccent;
      case 'below':
        return Colors.blueAccent;
      case 'normal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _tercileCardColor(String tercile) {
    switch (tercile) {
      case 'above':
        return Colors.red.shade100;
      case 'below':
        return Colors.blue.shade100;
      case 'normal':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
} 