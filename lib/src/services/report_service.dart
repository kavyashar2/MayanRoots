import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/report.dart';

class ReportService {
  static const String _reportsKey = 'reports';
  static const String _draftsKey = 'report_drafts';

  Future<void> saveReport(Report report) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await getReports();
    reports.add(report);
    
    final reportsJson = reports.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_reportsKey, reportsJson);
  }

  Future<void> saveDraft(Report report) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();
    drafts.add(report);
    
    final draftsJson = drafts.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_draftsKey, draftsJson);
  }

  Future<List<Report>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getStringList(_reportsKey) ?? [];
    
    return reportsJson
        .map((r) => Report.fromJson(jsonDecode(r)))
        .toList();
  }

  Future<List<Report>> getDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getStringList(_draftsKey) ?? [];
    
    return draftsJson
        .map((r) => Report.fromJson(jsonDecode(r)))
        .toList();
  }

  Future<void> deleteDraft(Report report) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();
    drafts.removeWhere((r) => 
      r.name == report.name && 
      r.date == report.date
    );
    
    final draftsJson = drafts.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_draftsKey, draftsJson);
  }
} 