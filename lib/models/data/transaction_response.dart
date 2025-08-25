import 'dart:convert';

import 'dto/currency_content.dart';
import 'dto/transaction_response_turkey.dart';
import 'dto/transaction_response_usa.dart';
import 'dto/language_content.dart';
import 'merchant.dart' as mr ;

// Define the main response object
class TransactionResponse {
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

  TransactionResponse({
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

  factory TransactionResponse.fromJson(dynamic json) {
    var performanceList = json['performance'] as List?;
    List<PerformanceDto>? performanceItems;

    if (performanceList != null) {
      performanceItems = performanceList.map((item) {
        return PerformanceDto.fromJson(item);
      }).toList();
    }

    var eventList = json['events'] as List;
    List<Event> eventItems =
        eventList.map((item) => Event.fromJson(item)).toList();

    return TransactionResponse(
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

  ReceiptDataTurkey getBKMReceipt() {
    if (data == null) {
      throw Exception("Data is null");
    }
    return ReceiptDataTurkey.fromJson(jsonDecode(data!));
  }

  ReceiptDataUSA getEPXReceipt() {
    if (data == null) {
      throw Exception("Data is null");
    }
    return ReceiptDataUSA.fromJson(jsonDecode(data!));
  }

  ReceiptData getMadaReceipt() {
    if (data == null) {
      throw Exception("Data is null");
    }
    return ReceiptData.fromJson(jsonDecode(data!));
  }
}

// Define the ReceiptData class
class ReceiptData {
  final String id;
  final mr.Merchant merchant;
  final CardScheme cardScheme;
  final String cardSchemeSponsor;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String tid;
  final String systemTraceAuditNumber;
  final String posSoftwareVersion;
  final String retrievalReferenceNumber;
  final TransactionType transactionType;
  final bool isApproved;
  final bool isRefunded;
  final bool isReversed;
  final ApprovalCode approvalCode;
  final String actionCode;
  final CurrencyContent statusMessage;
  final String pan;
  final String cardExpiration;
  final LabelField<String> amountAuthorized;
  final LabelField<String> amountOther;
  final CurrencyContent currency;
  final CurrencyContent verificationMethod;
  final CurrencyContent receiptLineOne;
  final CurrencyContent receiptLineTwo;
  final CurrencyContent thanksMessage;
  final CurrencyContent saveReceiptMessage;
  final String entryMode;
  final String applicationIdentifier;
  final String terminalVerificationResult;
  final String transactionStateInformation;
  final String cardholader_verfication_result;
  final String cryptogramInformationData;
  final String applicationCryptogram;
  final String kernelId;
  final String paymentAccountReference;
  final String? panSuffix;
  final String? customerReferenceNumber;
  final String qrCode;
  final String transactionUuid;
  final String? vasData;

  ReceiptData({
    required this.id,
    required this.merchant,
    required this.cardScheme,
    required this.cardSchemeSponsor,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.tid,
    required this.systemTraceAuditNumber,
    required this.posSoftwareVersion,
    required this.retrievalReferenceNumber,
    required this.transactionType,
    required this.isApproved,
    required this.isRefunded,
    required this.isReversed,
    required this.approvalCode,
    required this.actionCode,
    required this.statusMessage,
    required this.pan,
    required this.cardExpiration,
    required this.amountAuthorized,
    required this.amountOther,
    required this.currency,
    required this.verificationMethod,
    required this.receiptLineOne,
    required this.receiptLineTwo,
    required this.thanksMessage,
    required this.saveReceiptMessage,
    required this.entryMode,
    required this.applicationIdentifier,
    required this.terminalVerificationResult,
    required this.transactionStateInformation,
    required this.cardholader_verfication_result,
    required this.cryptogramInformationData,
    required this.applicationCryptogram,
    required this.kernelId,
    required this.paymentAccountReference,
    this.panSuffix,
    this.customerReferenceNumber,
    required this.qrCode,
    required this.transactionUuid,
    this.vasData,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    return ReceiptData(
     id: json['id'],
     merchant: mr.Merchant.fromJson(json['merchant']),
     cardScheme: CardScheme.fromJson(json['card_scheme']),
     cardSchemeSponsor: json['card_scheme_sponsor'],
     startDate: json['start_date'],
     startTime: json['start_time'],
     endDate: json['end_date'],
     endTime: json['end_time'],
     tid: json['tid'],
     systemTraceAuditNumber: json['system_trace_audit_number'],
     posSoftwareVersion: json['pos_software_version_number'],
     retrievalReferenceNumber: json['retrieval_reference_number'],
     transactionType: TransactionType.fromJson(json['transaction_type']),
     isApproved: json['is_approved'],
     isRefunded: json['is_refunded'],
     isReversed: json['is_reversed'],
     approvalCode: ApprovalCode.fromJson(json['approval_code']),
     actionCode: json['action_code'],
     statusMessage: CurrencyContent.fromJson(json['status_message']),
     pan: json['pan'],
     cardExpiration: json['card_expiration'],
     amountAuthorized: LabelField<String>.fromJson(json['amount_authorized']),
     amountOther: LabelField<String>.fromJson(json['amount_other']),
     currency: CurrencyContent.fromJson(json['currency']),
     verificationMethod: CurrencyContent.fromJson(json['verification_method']),
     receiptLineOne: CurrencyContent.fromJson(json['receipt_line_one']),
     receiptLineTwo: CurrencyContent.fromJson(json['receipt_line_two']),
     thanksMessage: CurrencyContent.fromJson(json['thanks_message']),
     saveReceiptMessage: CurrencyContent.fromJson(json['save_receipt_message']),
     entryMode: json['entry_mode'],
     applicationIdentifier: json['application_identifier'],
     terminalVerificationResult: json['terminal_verification_result'],
     transactionStateInformation: json['transaction_state_information'],
     cardholader_verfication_result: json['cardholader_verfication_result'],
     cryptogramInformationData: json['cryptogram_information_data'],
     applicationCryptogram: json['application_cryptogram'],
     kernelId: json['kernel_id'],
     paymentAccountReference: json['payment_account_reference'],
     panSuffix: json['pan_suffix'],
     customerReferenceNumber: json['customer_reference_number'],
     qrCode: json['qr_code'],
     transactionUuid: json['transaction_uuid'],
     vasData: json['vas_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
     'id': id,
      'merchant': merchant.toJson(),
      'card_scheme': cardScheme.toJson(),
      'card_scheme_sponsor': cardSchemeSponsor,
      'start_date': startDate,
      'start_time': startTime,
      'end_date': endDate,
      'end_time': endTime,
      'tid': tid,
      'system_trace_audit_number': systemTraceAuditNumber,
      'pos_software_version': posSoftwareVersion,
      'retrieval_reference_number': retrievalReferenceNumber,
      'transaction_type': transactionType.toJson(),
      'is_approved': isApproved,
      'is_refunded': isRefunded,
      'is_reversed': isReversed,
      'approval_code': approvalCode.toJson(),
      'action_code': actionCode,
      'status_message': statusMessage.toJson(),
      'pan': pan,
      'card_expiration': cardExpiration,
      'amount_authorized': amountAuthorized.toJson(),
      'amount_other': amountOther.toJson(),
      'currency': currency.toJson(),
      'verification_method': verificationMethod.toJson(),
      'receipt_line_one': receiptLineOne.toJson(),
      'receipt_line_two': receiptLineTwo.toJson(),
      'thanks_message': thanksMessage.toJson(),
      'save_receipt_message': saveReceiptMessage.toJson(),
      'entry_mode': entryMode,
      'application_identifier': applicationIdentifier,
      'terminal_verification_result': terminalVerificationResult,
      'transaction_state_information': transactionStateInformation,
      'cardholader_verfication_result': cardholader_verfication_result,
      'cryptogram_information_data': cryptogramInformationData,
      'application_cryptogram': applicationCryptogram,
      'kernel_id': kernelId,
      'payment_account_reference': paymentAccountReference,
      'pan_suffix': panSuffix,
      'customer_reference_number': customerReferenceNumber,
      'qr_code': qrCode,
      'transaction_uuid': transactionUuid,
      'vas_data': vasData,
    };
  }
}

class ApprovalCode {
  final String value;
  final LanguageContent label;

  ApprovalCode({
    required this.value,
    required this.label,
  });

  factory ApprovalCode.fromJson(Map<String, dynamic> json) {
    return ApprovalCode(
      value: json['value'],
      label: LanguageContent.fromJson(json['label']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label.toJson(),
    };
  }
}

class LabelField<T> {
  final T value;

  LabelField({required this.value});

  factory LabelField.fromJson(Map<String, dynamic> json) {
    return LabelField(
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}


class CardScheme {
  final LanguageContent name;
  final String id;

  CardScheme({
    required this.name,
    required this.id,
  });

  factory CardScheme.fromJson(Map<String, dynamic> json) {
    return CardScheme(
      name: LanguageContent.fromJson(json['name']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'id': id,
    };
  }
}

// Define the TransactionType class
class TransactionType {
  final String? id;
  final LanguageContent? name;

  TransactionType({
    required this.id,
    required this.name,
  });

  factory TransactionType.fromJson(dynamic json) {
    return TransactionType(
      id: json['id'],
      name: LanguageContent.fromJson(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name?.toJson(),
    };
  }
}
