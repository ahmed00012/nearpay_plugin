import 'dart:convert';

import 'currency_content.dart';

// Define the main response object
class TransactionResponseUSA {
  final String? id;
  final List<PerformanceDto>? performance;
  final String? cancelReason;
  final String? status;
  final CurrencyContent? currency;
  final String? createdAt;
  final String? completedAt;
  final String? referenceId;
  final String? orderId;
  final bool? pinRequired;
  final dynamic card;
  final List<Event>? events;
  final String? amountOther;

  TransactionResponseUSA({
    required this.id,
    this.performance,
    this.cancelReason,
    this.status,
    this.currency,
    this.createdAt,
    this.completedAt,
    this.referenceId,
    this.orderId,
    this.pinRequired,
    required this.card,
    required this.events,
    required this.amountOther,
  });

  factory TransactionResponseUSA.fromJson(dynamic json) {
    var performanceList = json['performance'] as List?;
    List<PerformanceDto>? performanceItems;

    if (performanceList != null) {
      performanceItems = performanceList.map((item) {
        // Ensure each item is a map
        // if (item is Map<String, dynamic>) {
        return PerformanceDto.fromJson(item);
        // } else {
        //   print('Item is not a Map<String, dynamic>');
        //   print("item $item");
        //   print("item ${item.toString()}");
        //   print("item ${item["timeStamp"]}");
        //   print("item ${item["type"]}");
        //   // Handle case when item is not a Map<String, dynamic>
        //   return PerformanceDto(type: '', timeStamp: 0); // Placeholder or handle error
        // }
      }).toList();
    }

    var eventList = json['events'] as List;
    List<Event> eventItems =
        eventList.map((item) => Event.fromJson(item)).toList();

    return TransactionResponseUSA(
      id: json['id'],
      performance: performanceItems,
      cancelReason: json['cancelReason'],
      status: json['status'],
      currency: json['currency'] != null
          ? CurrencyContent.fromJson(json['currency'])
          : null,
      createdAt: json['createdAt'],
      completedAt: json['completedAt'],
      referenceId: json['referenceId'],
      orderId: json['orderId'],
      pinRequired: json['pinRequired'],
      card: json['card'] != null ? Map<String, dynamic>.from(json['card']) : {},
      events: eventItems,
      amountOther: json['amountOther'],
    );
  }
}

// Define the PerformanceDto object
class PerformanceDto {
  final String? type;
  final double? timeStamp;

  PerformanceDto({required this.type, required this.timeStamp});

  factory PerformanceDto.fromJson(dynamic json) {
    return PerformanceDto(
      type: json['type'],
      timeStamp: json['timeStamp'],
    );
  }
}

// Define the Event object
class Event {
  final Receipt? receipt;
  final String? rrn;
  final String? status;

  Event({required this.receipt, required this.rrn, required this.status});

  factory Event.fromJson(dynamic json) {
    return Event(
      receipt: Receipt.fromJson(json['receipt']),
      rrn: json['rrn'],
      status: json['status'],
    );
  }
}

// Define the Receipt class
class Receipt {
  final String? standard;
  final String? id;
  final String? data;

  Receipt({
    required this.standard,
    required this.id,
    required this.data,
  });

  factory Receipt.fromJson(dynamic json) {
    return Receipt(
      standard: json['standard'],
      id: json['id'],
      data: json['data'],
    );
  }
}

// Define the ReceiptData class
class ReceiptDataUSA {
  final String transactionUuid;
  final List<String> supportedLanguages;
  final String receiptType;
  final String status;
  final String authCode;
  final String actionCode;
  final String amount;
  final AmountAuthorized amountAuthorized;
  final CurrencyContent currency;
  final String stan;
  final String rrn;
  final String tid;
  final String startAt;
  final String endAt;
  final String version;
  final CardInfo card;
  final MerchantInfo merchant;
  final List<MetaData> meta;
  final String? qrCode;

  ReceiptDataUSA({
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
    this.qrCode,
  });

  factory ReceiptDataUSA.fromJson(dynamic json) {
    return ReceiptDataUSA(
    transactionUuid: json['transaction_uuid'],
    supportedLanguages: List<String>.from(json['supported_languages']),
    receiptType: json['receipt_type'],
    status: json['status'],
    authCode: json['auth_code'],
    actionCode: json['action_code'],
    amount: json['amount'],
    amountAuthorized: AmountAuthorized.fromJson(json['amount_authorized']),
    currency: CurrencyContent.fromJson(json['currency']),
    stan: json['stan'],
    rrn: json['rrn'],
    tid: json['tid'],
    startAt: json['start_at'],
    endAt: json['end_at'],
    version: json['version'],
    card: CardInfo.fromJson(json['card']),
    merchant: MerchantInfo.fromJson(json['merchant']),
    meta: List<MetaData>.from(json['meta'].map((x) => MetaData.fromJson(x))),
    qrCode: json['qr_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_uuid': transactionUuid,
      'supported_languages': supportedLanguages,
      'receipt_type': receiptType,
      'status': status,
      'auth_code': authCode,
      'action_code': actionCode,
      'amount': amount,
      'amount_authorized': amountAuthorized.toJson(),
      'currency': currency.toJson(),
      'stan': stan,
      'rrn': rrn,
      'tid': tid,
      'start_at': startAt,
      'end_at': endAt,
      'version': version,
      'card': card.toJson(),
      'merchant': merchant.toJson(),
      'meta': meta.map((x) => x.toJson()).toList(),
      'qr_code': qrCode,
    };
  }
}

class MetaData {
  final String key;
  final String value;

  MetaData({
    required this.key,
    required this.value,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      key: json['key'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}

class MerchantInfo {
  final String id;
  final LocalizationFieldUSA name;
  final LocalizationFieldUSA address;
  final String phone;
  final String mcc;
  final BankInfo bank;

  MerchantInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.mcc,
    required this.bank,
  });

  factory MerchantInfo.fromJson(Map<String, dynamic> json) {
    return MerchantInfo(
      id: json['id'],
      name: LocalizationFieldUSA.fromJson(json['name']),
      address: LocalizationFieldUSA.fromJson(json['address']),
      phone: json['phone'],
      mcc: json['mcc'],
      bank: BankInfo.fromJson(json['bank']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'address': address.toJson(),
      'phone': phone,
      'mcc': mcc,
      'bank': bank.toJson(),
    };
  }
}

class LocalizationFieldUSA {
  final String english;
  final String arabic;

  LocalizationFieldUSA({
    required this.english,
    required this.arabic,
  });

  factory LocalizationFieldUSA.fromJson(Map<String, dynamic> json) {
    return LocalizationFieldUSA(
      english: json['english'],
      arabic: json['arabic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'english': english,
      'arabic': arabic,
    };
  }
}

class BankInfo {
  final String id;
  final LocalizationFieldUSA name;

  BankInfo({
    required this.id,
    required this.name,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      id: json['id'],
      name: LocalizationFieldUSA.fromJson(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
    };
  }
}

class CardInfo {
  final String brandCode;
  final String pan;
  final String exp;
  final String? panSuffix;

  CardInfo({
    required this.brandCode,
    required this.pan,
    required this.exp,
    this.panSuffix,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      brandCode: json['brand_code'],
      pan: json['pan'],
      exp: json['exp'],
      panSuffix: json['pan_suffix'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_code': brandCode,
      'pan': pan,
      'exp': exp,
      'pan_suffix': panSuffix,
    };
  }
}

// Define the Merchant class
class Merchant {
  final String? id;
  final String? name;
  final String? address;

  Merchant({
    required this.id,
    required this.name,
    required this.address,
  });

  factory Merchant.fromJson(dynamic json) {
    return Merchant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}

// Define the LocalizedText class
class LocalizedText {
  final String? english;
  final String? turkish;

  LocalizedText({
    required this.english,
    required this.turkish,
  });

  factory LocalizedText.fromJson(dynamic json) {
    return LocalizedText(
      english: json['english'],
      turkish: json['turkish'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'english': english,
      'turkish': turkish,
    };
  }
}

// Define the TransactionType class
class TransactionType {
  final String? id;
  final LocalizedText? name;

  TransactionType({
    required this.id,
    required this.name,
  });

  factory TransactionType.fromJson(dynamic json) {
    return TransactionType(
      id: json['id'],
      name: LocalizedText.fromJson(json['name']),
    );
  }
}

// Define the AmountAuthorized class
class AmountAuthorized {
  final LocalizedText? label;
  final String? value;

  AmountAuthorized({
    required this.label,
    required this.value,
  });

  factory AmountAuthorized.fromJson(dynamic json) {
    return AmountAuthorized(
      label: LocalizedText.fromJson(json['label']),
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label?.toJson(),
      'value': value,
    };
  }
}
