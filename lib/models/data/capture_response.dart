import 'package:flutter_terminal_sdk/models/data/authorized_receipt.dart';
class CaptureResponse {
  final String id;
  final String? amountOther;
  final CurrencyDto currency;
  final String? createdAt;
  final String? completedAt;
  final bool pinRequired;
  final List<PerformanceDto> performance;
  final CardDto? card;
  final List<CaptureEventDto> events;

  CaptureResponse({
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

  factory CaptureResponse.fromJson(Map<String, dynamic> json) {
    return CaptureResponse(
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

class CaptureEventDto {
  final CaptureReceiptDto? receipt;
  final String? rrn;
  final String? status;

  CaptureEventDto({
    this.receipt,
    this.rrn,
    this.status,
  });

  factory CaptureEventDto.fromJson(Map<String, dynamic> json) {
    return CaptureEventDto(
      receipt: json['receipt'] != null
          ? CaptureReceiptDto.fromJson(json['receipt'])
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

class CaptureReceiptDto {
  final String standard;
  final String id;
  final CaptureReceiptDataDto data;

  CaptureReceiptDto({
    required this.standard,
    required this.id,
    required this.data,
  });

  factory CaptureReceiptDto.fromJson(Map<String, dynamic> json) {
    return CaptureReceiptDto(
      standard: json['standard'],
      id: json['id'],
      data: CaptureReceiptDataDto.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'standard': standard,
      'id': id,
      'data': data.toJson(),
    };
  }
}

class CaptureReceiptDataDto {
  final String transactionUuid;
  final List<String> supportedLanguages;
  final String receiptType;
  final String status;
  final String authCode;
  final String actionCode;
  final String amount;
  final AmountAuthorizedDto amountAuthorized;
  final CurrencyDto currency;
  final String stan;
  final String rrn;
  final String tid;
  final String startAt;
  final String endAt;
  final String version;
  final CardDto card;
  final MerchantDto merchant;
  final List<MetaDto> meta;
  final String qrCode;

  CaptureReceiptDataDto({
    required this.transactionUuid,
    required this.supportedLanguages,
    required this.receiptType,
    required this.status,
    required this.authCode,
    required this.actionCode,
    required this.amount,
    required this.amountAuthorized,
    required this.currency,
    required this.stan,
    required this.rrn,
    required this.tid,
    required this.startAt,
    required this.endAt,
    required this.version,
    required this.card,
    required this.merchant,
    required this.meta,
    required this.qrCode,
  });

  factory CaptureReceiptDataDto.fromJson(Map<String, dynamic> json) {
    return CaptureReceiptDataDto(
      transactionUuid: json['transactionUuid'],
      supportedLanguages: List<String>.from(json['supportedLanguages'] ?? []),
      receiptType: json['receiptType'],
      status: json['status'],
      authCode: json['authCode'],
      actionCode: json['actionCode'],
      amount: json['amount'],
      amountAuthorized: AmountAuthorizedDto.fromJson(json['amountAuthorized']),
      currency: CurrencyDto.fromJson(json['currency']),
      stan: json['stan'],
      rrn: json['rrn'],
      tid: json['tid'],
      startAt: json['startAt'],
      endAt: json['endAt'],
      version: json['version'],
      card: CardDto.fromJson(json['card']),
      merchant: MerchantDto.fromJson(json['merchant']),
      meta: (json['meta'] as List)
          .map((e) => MetaDto.fromJson(e))
          .toList(),
      qrCode: json['qrCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionUuid': transactionUuid,
      'supportedLanguages': supportedLanguages,
      'receiptType': receiptType,
      'status': status,
      'authCode': authCode,
      'actionCode': actionCode,
      'amount': amount,
      'amountAuthorized': amountAuthorized.toJson(),
      'currency': currency.toJson(),
      'stan': stan,
      'rrn': rrn,
      'tid': tid,
      'startAt': startAt,
      'endAt': endAt,
      'version': version,
      'card': card.toJson(),
      'merchant': merchant.toJson(),
      'meta': meta.map((e) => e.toJson()).toList(),
      'qrCode': qrCode,
    };
  }
}


