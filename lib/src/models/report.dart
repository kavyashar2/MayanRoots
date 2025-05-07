class Report {
  final String name;
  final String category;
  final String? agriculturalCyclePhase;
  final String description;
  final String? location;
  final String? yield;
  final DateTime date;

  Report({
    required this.name,
    required this.category,
    this.agriculturalCyclePhase,
    required this.description,
    this.location,
    this.yield,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'agriculturalCyclePhase': agriculturalCyclePhase,
    'description': description,
    'location': location,
    'yield': yield,
    'date': date.toIso8601String(),
  };

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    name: json['name'],
    category: json['category'],
    agriculturalCyclePhase: json['agriculturalCyclePhase'],
    description: json['description'],
    location: json['location'],
    yield: json['yield'],
    date: DateTime.parse(json['date']),
  );
} 