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
            title: Text('${widget.year} Forecast'),
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
                            const Text('No forecast available for this month.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(height: 8),
                            const Text(
                              'Why are some months missing?',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Seasonal forecasts are made for future months, and sometimes not every month has a forecast. This can happen because forecasts are made several months ahead, or because the data provider did not release a forecast for that month. Sometimes, forecasts are missing due to data quality checks or gaps in the original data. This is normal and does not mean there is a problem with your app.',
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
                              _tercileLabel(dominant),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _tercileColor(dominant)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Hotter: $above%   Normal: $normal%   Colder: $below%', style: const TextStyle(fontSize: 15)),
                          const SizedBox(height: 8),
                          _farmerExplanation(dominant, prob, monthLabel),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'Data source: IRI NMME, CHIRPS',
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
                      'Note: Some months may not have a forecast due to unavailable data. This is normal for seasonal forecasts.\n\n'
                      'How to use this page:\n'
                      '- Each card shows the forecast for a month, with the most likely temperature outcome and the chances for hotter, normal, or colder than usual.\n'
                      '- If a month is missing, it means no forecast was available for that month.\n\n'
                      'How this helps you:\n'
                      '- Use these forecasts to plan your planting, growing, and harvesting.\n'
                      '- If a month is likely to be hotter, consider watering more or planting heat-tolerant crops.\n'
                      '- If a month is likely to be colder, be ready for possible cold stress.\n'
                      '- If normal, expect a typical season.\n\n'
                      'If you have questions, ask your local advisor for more information.\n\n',
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data source: Seasonal climate forecasts provided by the Mayan Roots backend and international climate agencies (e.g., NOAA, CONAGUA, CHIRPS).',
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

  Widget _farmerExplanation(String dominant, String prob, String monthLabel) {
    switch (dominant) {
      case 'above':
        return Text('This means there is a $prob% chance that $monthLabel will be hotter than usual. Prepare your crops for more heat.', style: const TextStyle(fontSize: 15, color: Colors.redAccent));
      case 'below':
        return Text('This means there is a $prob% chance that $monthLabel will be colder than usual. Be ready for possible cold weather.', style: const TextStyle(fontSize: 15, color: Colors.blueAccent));
      case 'normal':
        return Text('This means there is a $prob% chance that $monthLabel will have normal temperatures. Expect a typical season.', style: const TextStyle(fontSize: 15, color: Colors.green));
      default:
        return Text('We do not have enough information for $monthLabel. Please ask your local advisor for more details.', style: const TextStyle(fontSize: 15, color: Colors.grey));
    }
  }

  void _showForecastDetail(BuildContext context, Map<String, dynamic> forecast) {
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
              Text('Most likely: \\${_tercileLabel(dominant)} (\\$prob%)', style: TextStyle(color: _tercileColor(dominant), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Lead time: \\${lead} month(s)'),
              Text('Issued: \\${issued}'),
              // (Optional) Add advice/explanation here
              if (dominant == 'above')
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text('Advice: Prepare for heat stress on crops.', style: TextStyle(color: Colors.redAccent)),
                ),
              if (dominant == 'below')
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text('Advice: Prepare for possible cold stress.', style: TextStyle(color: Colors.blueAccent)),
                ),
              if (dominant == 'normal')
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text('Advice: Expect typical seasonal temperatures.', style: TextStyle(color: Colors.green)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _tercileLabel(String tercile) {
    switch (tercile) {
      case 'above':
        return 'Above-normal temperature';
      case 'below':
        return 'Below-normal temperature';
      case 'normal':
        return 'Near-normal temperature';
      default:
        return 'Unknown';
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