import 'package:flutter/material.dart';
import '../services/sheets_service.dart';
import '../services/localization_service.dart';
import 'package:provider/provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _formKey = GlobalKey<FormState>();
  final _sheetsService = SheetsService();
  bool _isLoading = false;
  String? _error;

  // Form controllers
  final _reportNameController = TextEditingController();
  String? _selectedCategory;
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _cropYieldController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSheetsService();
  }

  Future<void> _initializeSheetsService() async {
    setState(() => _isLoading = true);
    try {
      await _sheetsService.init();
      if (mounted) {
        setState(() {
          _error = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reportNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _cropYieldController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final success = await _sheetsService.insertReport(
          reportName: _reportNameController.text,
          category: _selectedCategory ?? '',
          description: _descriptionController.text,
          location: _locationController.text,
          cropYield: _cropYieldController.text,
          email: _emailController.text,
          incidentDate: _dateController.text,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Provider.of<LocalizationService>(context, listen: false).translate('success')),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Provider.of<LocalizationService>(context, listen: false).translate('error')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${Provider.of<LocalizationService>(context, listen: false).translate('error')}: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _dateController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localization, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFA8D5BA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              localization.translate('reports_title'),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          body: _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      ElevatedButton(
                        onPressed: _initializeSheetsService,
                        child: Text(localization.translate('try_again')),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localization.translate('new_report'),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    localization.translate('report_name'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _reportNameController,
                                    decoration: InputDecoration(
                                      hintText: localization.translate('report_name_hint'),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return localization.translate('report_name_error');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    localization.translate('description'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _descriptionController,
                                    decoration: InputDecoration(
                                      hintText: localization.translate('description_hint'),
                                      border: const OutlineInputBorder(),
                                    ),
                                    maxLines: 4,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return localization.translate('description_error');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    localization.translate('location'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _locationController,
                                    decoration: InputDecoration(
                                      hintText: localization.translate('location_hint'),
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    localization.translate('crop_yield'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _cropYieldController,
                                    decoration: InputDecoration(
                                      hintText: localization.translate('crop_yield_hint'),
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    localization.translate('email_optional'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      hintText: localization.translate('email_hint'),
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    localization.translate('incident_date'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _dateController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    readOnly: true,
                                    onTap: _selectDate,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _submitReport,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFA8D5BA),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: Text(
                                        localization.translate('submit_report'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
} 