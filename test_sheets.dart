import 'package:mayan_roots_app/src/services/sheets_service.dart';

void main() async {
  print('Starting Sheets Service test...');
  
  final sheetsService = SheetsService();
  
  try {
    print('Initializing service...');
    await sheetsService.init();
    print('Service initialized successfully');
    
    print('\nAttempting to insert a test report...');
    final success = await sheetsService.insertReport(
      reportName: 'Test Report',
      category: 'Test Category',
      description: 'This is a test report to verify sheets integration',
      location: 'Test Location',
      cropYield: 'Test Yield',
      incidentDate: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );
    
    if (success) {
      print('\n✅ SUCCESS: Test report was inserted successfully!');
    } else {
      print('\n❌ ERROR: Failed to insert test report');
    }
  } catch (e) {
    print('\n❌ ERROR: ${e.toString()}');
    print('\nStack trace:');
    print('====================');
    print(e);
    print('====================');
  }
} 