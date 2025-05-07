import 'package:flutter/material.dart';
import '../services/sheets_service.dart';
import '../services/localization_service.dart';
import 'package:provider/provider.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _sheetsService = SheetsService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _isLoading = false;

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
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _sheetsService.insertReport(
        reportName: 'Feedback from ${_nameController.text}',
        category: 'Feedback',
        description: _feedbackController.text,
        location: _emailController.text,  // Using location field for email
        cropYield: _mobileController.text,  // Using cropYield field for mobile
        incidentDate: DateTime.now().toString(),
      );

      if (!mounted) return;

      final localization = Provider.of<LocalizationService>(context, listen: false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localization.translate('feedback_success')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localization.translate('feedback_error')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final localization = Provider.of<LocalizationService>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localization.translate('feedback_error')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              localization.translate('feedback_title'),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: localization.translate('name'),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return localization.translate('name_error');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: localization.translate('email'),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true || !value!.contains('@')) {
                            return localization.translate('email_error');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mobileController,
                        decoration: InputDecoration(
                          labelText: localization.translate('mobile'),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true || value!.length < 10) {
                            return localization.translate('mobile_error');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _feedbackController,
                        decoration: InputDecoration(
                          labelText: localization.translate('feedback'),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return localization.translate('feedback_error');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(localization.translate('submit_feedback')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 