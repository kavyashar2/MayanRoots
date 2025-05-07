import 'package:flutter/material.dart';
import 'services/sheets_service.dart';

class SheetsTestWidget extends StatefulWidget {
  const SheetsTestWidget({super.key});

  @override
  State<SheetsTestWidget> createState() => _SheetsTestWidgetState();
}

class _SheetsTestWidgetState extends State<SheetsTestWidget> {
  String _status = 'Not started';
  bool _isLoading = false;

  Future<void> _runTest() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _status = 'Starting test...';
    });

    try {
      final sheetsService = SheetsService();
      
      setState(() => _status = 'Initializing service...');
      await sheetsService.init();
      setState(() => _status = 'Service initialized successfully');
      
      setState(() => _status = 'Attempting to write test report...');
      final success = await sheetsService.insertReport(
        reportName: 'API Test Report',
        category: 'Test',
        description: 'Testing API connectivity',
        location: 'Test Location',
        cropYield: 'Test Yield',
        incidentDate: DateTime.now().toString(),
      );
      
      if (success) {
        setState(() => _status = '✅ Test successful: Report written');
      } else {
        setState(() => _status = '❌ Test failed: Could not write report');
      }
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sheets API Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _runTest,
                  child: const Text('Run Test'),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 