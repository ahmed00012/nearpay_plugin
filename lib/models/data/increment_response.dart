import 'package:flutter_terminal_sdk/models/data/authorized_receipt.dart';

class IncrementResponse {
  final String id;
  final String? amountOther;
  final CurrencyDto currency;
  final String? createdAt;
  final String? completedAt;
  final bool pinRequired;
  final List<PerformanceDto> performance;
  final CardDto? card;
  final List<IncrementEventDto> events;

  IncrementResponse({
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

  factory IncrementResponse.fromJson(Map<String, dynamic> json) {
    return IncrementResponse(
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
          .map((item) => IncrementEventDto.fromJson(item))
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

class IncrementEventDto {
  final AuthReceiptDto? receipt;
  final String? rrn;
  final String? status;

  IncrementEventDto({
    this.receipt,
    this.rrn,
    this.status,
  });

  factory IncrementEventDto.fromJson(Map<String, dynamic> json) {
    return IncrementEventDto(
      receipt: json['receipt'] != null
          ? AuthReceiptDto.fromJson(json['receipt'])
          : null,
      rrn: json['rrn'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receipt': receipt?.toJson(),
      'rrn': rrn,
      'status': status,
    };
  }
}
