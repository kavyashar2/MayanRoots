import 'package:cloud_firestore/cloud_firestore.dart';

class WeatherForecast {
  final ShortTermForecast shortTerm;
  final LongTermForecast longTerm;
  final DateTime updatedAt;

  WeatherForecast({
    required this.shortTerm,
    required this.longTerm,
    required this.updatedAt,
  });

  factory WeatherForecast.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeatherForecast(
      shortTerm: ShortTermForecast.fromMap(data['short_term'] as Map<String, dynamic>),
      longTerm: LongTermForecast.fromMap(data['long_term'] as Map<String, dynamic>),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'short_term': shortTerm.toJson(),
    'long_term': longTerm.toJson(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      shortTerm: ShortTermForecast.fromMap(json['short_term'] as Map<String, dynamic>),
      longTerm: LongTermForecast.fromMap(json['long_term'] as Map<String, dynamic>),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class ShortTermForecast {
  final double precipMm;
  final double confidence;

  ShortTermForecast({
    required this.precipMm,
    required this.confidence,
  });

  factory ShortTermForecast.fromMap(Map<String, dynamic> map) {
    return ShortTermForecast(
      precipMm: (map['precip_mm'] as num).toDouble(),
      confidence: (map['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'precip_mm': precipMm,
    'confidence': confidence,
  };
}

class LongTermForecast {
  final double wetProbability;
  final double dryProbability;
  final double normalProbability;

  LongTermForecast({
    required this.wetProbability,
    required this.dryProbability,
    required this.normalProbability,
  });

  factory LongTermForecast.fromMap(Map<String, dynamic> map) {
    return LongTermForecast(
      wetProbability: (map['wet_probability'] as num).toDouble(),
      dryProbability: (map['dry_probability'] as num).toDouble(),
      normalProbability: (map['normal_probability'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'wet_probability': wetProbability,
    'dry_probability': dryProbability,
    'normal_probability': normalProbability,
  };
} 