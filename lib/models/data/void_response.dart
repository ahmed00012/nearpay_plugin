import 'authorized_receipt.dart';
import 'capture_response.dart';

class VoidResponse {
  final String id;
  final String? amountOther;
  final CurrencyDto currency;
  final String? createdAt;
  final String? completedAt;
  final bool pinRequired;
  final List<PerformanceDto> performance;
  final CardDto? card;
  final List<CaptureEventDto> events;

  VoidResponse({
    required this.id,
    this.amountOther,
    required this.currency,
    this.createdAt,
    this.completedAt,
    required this.pinRequired,
    required this.performance,
    this.card,
    required this.events,
  });

  factory VoidResponse.fromJson(Map<String, dynamic> json) {
    return VoidResponse(
      id: json['id'],
      amountOther: json['amountOther'],
      currency: CurrencyDto.fromJson(json['currency']),
      createdAt: json['createdAt'],
      completedAt: json['completedAt'],
      pinRequired: json['pinRequired'],
      performance: (json['performance'] as List)
          .map((item) => PerformanceDto.fromJson(item))
          .toList(),
      card: json['card'] != null ? CardDto.fromJson(json['card']) : null,
      events: (json['events'] as List)
          .map((item) => CaptureEventDto.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountOther': amountOther,
      'currency': currency.toJson(),
      'createdAt': createdAt,
      'completedAt': completedAt,
      'pinRequired': pinRequired,
      'performance': performance.map((e) => e.toJson()).toList(),
      'card': card?.toJson(),
      'events': events.map((e) => e.toJson()).toList(),
    };
  }
}
