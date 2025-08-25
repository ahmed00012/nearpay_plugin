// lib/models/terminal_response.dart

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_terminal_sdk/models/data/reconciliation_list_response.dart';
import 'package:flutter_terminal_sdk/models/purchase_void_callbacks.dart';
import 'package:flutter_terminal_sdk/models/authorized_callbacks.dart';
import 'package:flutter_terminal_sdk/models/refund_callbacks.dart';
import 'package:flutter_terminal_sdk/models/data/transaction_response.dart';
import 'package:flutter_terminal_sdk/models/refund_void_callbacks.dart';
import 'package:flutter_terminal_sdk/models/transactions_response.dart';
import '../errors/errors.dart';
import '../helper/helper.dart';
import 'card_reader_callbacks.dart';
import 'data/dto/transaction_response_turkey.dart';
import 'data/receipts_response.dart';
import 'data/reconcile_response.dart';
import 'data/reconciliation_receipts_response.dart';
import 'data/authorized_receipt.dart';
import 'data/increment_response.dart';
import 'data/capture_response.dart';
import 'data/void_response.dart';
import 'purchase_callbacks.dart';
import 'data/payment_scheme.dart';

class TerminalModel {
  final String tid;
  final String name;
  final bool isReady;
  final String terminalUUID;
  final String uuid;
  final MethodChannel _channel = const MethodChannel('nearpay_plugin');
  final Map<String, AuthorizedCallbacks> _activeAuthorizeCallbacks = {};
  final Map<String, PurchaseCallbacks> _activePurchaseCallbacks = {};
  final Map<String, PurchaseVoidCallbacks> _activePurchaseVoidCallbacks = {};
  final Map<String, RefundCallbacks> _activeRefundCallbacks = {};
  final Map<String, RefundVoidCallbacks> _activeRefundVoidCallbacks = {};

  TerminalModel({required this.tid,
    required this.name,
    required this.isReady,
    required this.terminalUUID,
    required this.uuid}) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  factory TerminalModel.fromJson(Map<String, dynamic> json) {
    return TerminalModel(
      tid: json['tid'] as String,
      isReady: json['isReady'] as bool? ?? false,
      terminalUUID: json['terminalUUID'] as String,
      uuid: json['uuid'] as String,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'tid': tid,
        'isReady': isReady,
        'terminalUUID': terminalUUID,
        'uuid': uuid,
        'name': name,
      };

  @override
  String toString() {
    return 'TerminalModel(tid: $tid, isReady: $isReady, terminalUUID: $terminalUUID, uuid: $uuid , name: $name)';
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'purchaseEvent' ||
        call.method == 'refundEvent' ||
        call.method == 'purchaseVoidEvent' ||
        call.method == 'refundVoidEvent') {
      final args = Map<String, dynamic>.from(call.arguments);
      final transactionUuid = args['transactionUuid'] as String;
      final eventType = args['type'] as String;
      final message = args['message'] as String?;

      final rawData = args['data'];
      Map<String, dynamic>? data;

      if (rawData is String) {
        // If data is a JSON string, decode it
        try {
          data = jsonDecode(rawData);
        } catch (e) {
          // print("Error decoding JSON string for $eventType: $e");
        }
      } else if (rawData is Map) {
        // If data is already a map, cast it properly
        data = Map<String, dynamic>.from(rawData);
      }

      switch (call.method) {
        case 'purchaseEvent':
          final PurchaseCallbacks? callbacks =
          _activePurchaseCallbacks[transactionUuid];

          if (callbacks == null) {
            print(
                "No active purchase callbacks for transactionUuid: $transactionUuid");
            return;
          }

          _handleEvent(
              eventType,
              message,
              data,
              callbacks.cardReaderCallbacks,
              callbacks.onSendTransactionCompleted,
              callbacks.onSendTransactionFailure);
          break;
        case 'authorizeEvent':
          final AuthorizedCallbacks? callbacks =
          _activeAuthorizeCallbacks[transactionUuid];

          if (callbacks == null) {
            print(
                "No active authorized callbacks for transactionUuid: $transactionUuid");
            return;
          }

          _handleEvent(
              eventType,
              message,
              data,
              callbacks.cardReaderCallbacks,
              callbacks.onSendAuthorizedCompleted,
              callbacks.onSendTransactionFailure);
          break;
        case 'refundEvent':
          final RefundCallbacks? callbacks =
          _activeRefundCallbacks[transactionUuid];

          if (callbacks == null) {
            print(
                "No active refund callbacks for transactionUuid: $transactionUuid");
            return;
          }

          _handleEvent(
              eventType,
              message,
              data,
              callbacks.cardReaderCallbacks,
              callbacks.onSendTransactionCompleted,
              callbacks.onSendTransactionFailure);
          break;
        case 'purchaseVoidEvent':
          final PurchaseVoidCallbacks? callbacks =
          _activePurchaseVoidCallbacks[transactionUuid];

          if (callbacks == null) {
            print(
                "No active purchase void callbacks for transactionUuid: $transactionUuid");
            return;
          }

          _handleEvent(
              eventType,
              message,
              data,
              callbacks.cardReaderCallbacks,
              callbacks.onSendTransactionCompleted,
              callbacks.onSendTransactionFailure);
          break;
        case 'refundVoidEvent':
          final RefundVoidCallbacks? callbacks =
          _activeRefundVoidCallbacks[transactionUuid];

          if (callbacks == null) {
            print(
                "No active refund void callbacks for transactionUuid: $transactionUuid");
            return;
          }

          _handleEvent(
              eventType,
              message,
              data,
              callbacks.cardReaderCallbacks,
              callbacks.onSendTransactionCompleted,
              callbacks.onSendTransactionFailure);
          break;
      }
    }
  }

  void _handleEvent(String eventType,
      String? message,
      Map<String, dynamic>? data,
      CardReaderCallbacks? cardReaderCallbacks,
      Function? onSuccess,
      Function(String)? onFailure,) {
    switch (eventType) {
      case 'readerDisplayed' :
        cardReaderCallbacks?.onReaderDisplayed?.call();
        break;
      case 'readerClosed':
        cardReaderCallbacks?.onReaderClosed?.call();
        break;
      case 'readingStarted':
        cardReaderCallbacks?.onReadingStarted?.call();
        break;
      case 'readerWaiting':
        cardReaderCallbacks?.onReaderWaiting?.call();
        break;
      case 'readerReading':
        cardReaderCallbacks?.onReaderReading?.call();
        break;
      case 'readerRetry':
        cardReaderCallbacks?.onReaderRetry?.call();
        break;
      case 'pinEntering':
        cardReaderCallbacks?.onPinEntering?.call();
        break;
      case 'readerFinished':
        cardReaderCallbacks?.onReaderFinished?.call();
        break;
      case 'readerError':
        if (message != null) {
          cardReaderCallbacks?.onReaderError?.call(message);
        }
        break;
      case 'cardReadSuccess':
        cardReaderCallbacks?.onCardReadSuccess?.call();
        break;
      case 'cardReadFailure':
        if (message != null) {
          cardReaderCallbacks?.onCardReadFailure?.call(message);
        }
        break;
      case 'sendTransactionFailure':
        if (message != null) {
          onFailure?.call(message);
        }
        break;
      case 'authorizeFailure':
        if (message != null) {
          onFailure?.call(message);
        }
        break;
      case 'sendTransactionCompleted':
        if (data != null) {
          try {
            final transactionResponse = TransactionResponse.fromJson(data);
            onSuccess?.call(transactionResponse);
          } catch (e) {
            onFailure?.call("Error parsing TransactionResponse: $e");
            // print("Error parsing TransactionResponse: $e");
          }
        }
        break;
      case 'authorizeCompleted':
        if (data != null) {
          try {
            final transactionResponse = AuthorizeReceipt.fromJson(data);
            onSuccess?.call(transactionResponse);
          } catch (e) {
            onFailure?.call("Error parsing TransactionResponse: $e");
          }
        }
        break;
      case 'sendTransactionVoidCompleted':
        if (data != null) {
          try {
            final transactionResponse =
            TransactionResponseTurkey.fromJson(data);
            onSuccess?.call(transactionResponse);
          } catch (e) {
            onFailure?.call("Error parsing TransactionResponse: $e");
          }
        }
        break;
      default:
        onFailure?.call("Unknown event type: $eventType");
        break;
    }
  }

  void dispose() {
    _activePurchaseCallbacks.clear();
    _activeRefundCallbacks.clear();
    _activePurchaseVoidCallbacks.clear();
    _activeRefundVoidCallbacks.clear();
    _activeAuthorizeCallbacks.clear();
  }

  /// reverseTerminal
  Future<TransactionResponse> reverse({
    required String transitionId,
  }) async {
    final response = await callAndReturnMapResponse(
      'reverse',
      {
        'terminalUUID': terminalUUID,
        'transitionId': transitionId,
      },
      _channel,
    );

    final status = response['status'];
    if (status == 'success') {
      final data = response['data'] as Map<String, dynamic>;
      return TransactionResponse.fromJson(data);
    } else {
      final message = response['message'] ?? 'Failed to reverse transaction';
      throw NearpayException(message);
    }
  }

  Future<String> purchase({
    required String transactionUuid,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    required PurchaseCallbacks callbacks,
  }) async {
    _activePurchaseCallbacks[transactionUuid] = callbacks;

    try {
      final response = await callAndReturnMapResponse(
        'purchase',
        {
          "uuid": terminalUUID,
          "amount": amount,
          "scheme": scheme != null ? scheme?.name : null,
          "transactionUuid": transactionUuid,
          "customerReferenceNumber": customerReferenceNumber,
        },
        _channel,
      );

      if (response["status"] == "success") {
        return transactionUuid;
      } else {
        _activePurchaseCallbacks.remove(transactionUuid);
        throw NearpayException(response["message"] ?? "Purchase failed");
      }
    } catch (e) {
      _activePurchaseCallbacks.remove(transactionUuid);
      rethrow;
    }
  }

  Future<String> purchaseVoid({
    required String transactionUuid,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    required PurchaseVoidCallbacks callbacks,
  }) async {
    _activePurchaseVoidCallbacks[transactionUuid] = callbacks;

    try {
      final response = await callAndReturnMapResponse(
        'purchaseVoid',
        {
          "uuid": terminalUUID,
          "amount": amount,
          "scheme": scheme != null ? scheme?.name : null,
          "transactionUuid": transactionUuid,
          "customerReferenceNumber": customerReferenceNumber,
        },
        _channel,
      );

      if (response["status"] == "success") {
        return transactionUuid;
      } else {
        _activePurchaseVoidCallbacks.remove(transactionUuid);
        throw NearpayException(response["message"] ?? "Purchase failed");
      }
    } catch (e) {
      _activePurchaseVoidCallbacks.remove(transactionUuid);
      rethrow;
    }
  }

  Future<String> refund({
    required String transactionUuid,
    required String refundUuid,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    required RefundCallbacks callbacks,
  }) async {
    _activeRefundCallbacks[transactionUuid] = callbacks;

    try {
      final response = await callAndReturnMapResponse(
        'refund',
        {
          "terminalUUID": terminalUUID,
          "transactionUuid": transactionUuid,
          "refundUuid": refundUuid,
          "amount": amount,
          "customerReferenceNumber": customerReferenceNumber,
          "scheme": scheme != null ? scheme?.name : null,
        },
        _channel,
      );

      if (response["status"] == "success") {
        return refundUuid;
      } else {
        _activeRefundCallbacks.remove(transactionUuid);
        throw NearpayException(response["message"] ?? "Refund failed");
      }
    } catch (e) {
      _activeRefundCallbacks.remove(transactionUuid);
      rethrow;
    }
  }

  Future<String> refundVoid({
    required String refundUuid,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    required RefundVoidCallbacks callbacks,
  }) async {
    _activeRefundVoidCallbacks[refundUuid] = callbacks;

    try {
      final response = await callAndReturnMapResponse(
        'refundVoid',
        {
          "terminalUUID": terminalUUID,
          "refundUuid": refundUuid,
          "amount": amount,
          "customerReferenceNumber": customerReferenceNumber,
          "scheme": scheme != null ? scheme?.name : null,
        },
        _channel,
      );

      if (response["status"] == "success") {
        return refundUuid;
      } else {
        _activeRefundVoidCallbacks.remove(refundUuid);
        throw NearpayException(response["message"] ?? "Refund failed");
      }
    } catch (e) {
      _activeRefundVoidCallbacks.remove(refundUuid);
      rethrow;
    }
  }

  Future<ReceiptsResponse> getTransactionDetails({
    required String transactionUuid,
  }) async {
    try {
      final response = await callAndReturnMapResponse(
        'getTransactionDetails',
        {
          "terminalUUID": terminalUUID,
          "transactionUUID": transactionUuid,
        },
        _channel,
      );

      if (response["status"] == "success") {
        return ReceiptsResponse.fromJson(response['data']);
      } else {
        throw NearpayException(
            response["message"] ?? "Get Transaction Details Failed");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionsResponse> getTransactionsList({
    int? page,
    int? pageSize,
    bool? isReconciled,
    num? date,
    num? startDate,
    num? endDate,
    String? customerReferenceNumber,
  }) async {
    final result = await callAndReturnMapResponse(
      'getTransactionsList',
      {
        "terminalUUID": terminalUUID,
        "page": page,
        "pageSize": pageSize,
        "isReconciled": isReconciled,
        "date": date,
        "startDate": startDate,
        "endDate": endDate,
        "customerReferenceNumber": customerReferenceNumber,
      },
      _channel,
    );
    final status = result['status'];
    if (status == 'success') {
      final data = result['data'] as Map<String, dynamic>;

      final myData = TransactionsResponse.fromJson(data);
      return myData;
    } else {
      final message = result['message'] ?? 'Unknown error';
      throw NearpayException('Failed to retrieve Transactions: $message');
    }
  }

  Future<ReconciliationResponse> getReconcileDetails({
    required String uuid,
  }) async {
    try {
      final response = await callAndReturnMapResponse(
        'getReconcileDetails',
        {
          "terminalUUID": terminalUUID,
          "uuid": uuid,
        },
        _channel,
      );

      if (response["status"] == "success") {
        final data = response['data'] as Map<String, dynamic>;
        return ReconciliationResponse.fromJson(data);
      } else {
        throw NearpayException(
            response["message"] ?? "Get Reconcile Details Failed");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ReconciliationListResponse> getReconcileList({
    int? page,
    int? pageSize,
    num? startDate,
    num? endDate,
  }) async {
    final result = await callAndReturnMapResponse(
      'getReconcileList',
      {
        "terminalUUID": terminalUUID,
        "page": page,
        "pageSize": pageSize,
        "startDate": startDate,
        "endDate": endDate,
      },
      _channel,
    );
    final status = result['status'];
    if (status == 'success') {
      final data = result['data'] as Map<String, dynamic>;
      return ReconciliationListResponse.fromJson(data);
    } else {
      final message = result['message'] ?? 'Unknown error';
      throw NearpayException('Failed to retrieve Reconcile: $message');
    }
  }

  Future<ReconciliationReceiptsResponse> reconcile() async {
    final response = await callAndReturnMapResponse(
      'reconcile',
      {
        'terminalUUID': terminalUUID,
      },
      _channel,
    );

    final status = response['status'];
    if (status == 'success') {
      final data = response['data'] as Map<String, dynamic>;
      final dataModel = ReconciliationReceiptsResponse.fromJson(data);
      return dataModel;
    } else {
      final message = response['message'] ?? 'Failed to connect to terminal';
      throw NearpayException(message);
    }
  }

  Future<bool> cancel({required String transactionUUID}) async {
    final response = await callAndReturnMapResponse(
      'cancel',
      {
        'terminalUUID': terminalUUID,
        'transactionUUID': transactionUUID,
      },
      _channel,
    );

    final status = response['status'];
    if (status == 'success') {
      final data = response['data'] as Map<String, dynamic>;
      return data['canceled'] as bool;
    } else {
      final message = response['message'] ?? 'Failed to cancel transaction';
      throw NearpayException(message);
    }
  }

  // authorize
  Future<String> authorize({
    required String uuid,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    required AuthorizedCallbacks callbacks,
  }) async {
    _activeAuthorizeCallbacks[uuid] = callbacks;

    try {
      final response = await callAndReturnMapResponse(
        'authorize',
        {
          "terminalUUID": terminalUUID,
          "amount": amount,
          "scheme": scheme != null ? scheme?.name : null,
          "uuid": uuid,
          "customerReferenceNumber": customerReferenceNumber,
        },
        _channel,
      );

      if (response["status"] == "success") {
        return uuid;
      } else {
        _activeAuthorizeCallbacks.remove(uuid);
        throw NearpayException(response["message"] ?? "Purchase failed");
      }
    } catch (e) {
      _activeAuthorizeCallbacks.remove(uuid);
      rethrow;
    }
  }

  // authorizeVoid
  Future<VoidResponse> authorizeVoid({
    required String id,
  }) async {
    final response = await callAndReturnMapResponse(
      'authorizeVoid',
      {
        'terminalUUID': terminalUUID,
        'id': id,
      },
      _channel,
    );

    final status = response['status'];
    if (status == 'success') {
      final data = response['data'] as Map<String, dynamic>;
      return VoidResponse.fromJson(data);
    } else {
      final message = response['message'] ??
          'Failed to void authorization';
      throw NearpayException(message);
    }
  }

  // incrementAuthorization
  Future<IncrementResponse> incrementAuthorization({
    required String uuid,
    required String authorizationUuid,
    required int amount,
  }) async {
    final response = await callAndReturnMapResponse(
      'incrementAuthorization',
      {
        'terminalUUID': terminalUUID,
        'uuid': uuid,
        'authorizationUuid': authorizationUuid,
        'amount': amount,
      },
      _channel,
    );

    final status = response['status'];
    if (status == 'success') {
      final data = response['data'] as Map<String, dynamic>;
      return IncrementResponse.fromJson(data);
    } else {
      final message = response['message'] ??
          'Failed to increment authorization';
      throw NearpayException(message);
    }
  }


  // captureAuthorization
  Future<CaptureResponse> captureAuthorization({
    required String uuid,
    required String authorizationUuid,
    required int amount,
  }) async {
    final response = await callAndReturnMapResponse(
      'captureAuthorization',
      {
        'terminalUUID': terminalUUID,
        'authorizationUuid': authorizationUuid,
        'uuid': uuid,
        'amount': amount,
      },
      _channel,
    );

    final status = response['status'];
    if (status == 'success') {
      final data = response['data'] as Map<String, dynamic>;
      return CaptureResponse.fromJson(data);
    } else {
      final message = response['message'] ?? 'Failed to capture authorization';
      throw NearpayException(message);
    }
  }

}
