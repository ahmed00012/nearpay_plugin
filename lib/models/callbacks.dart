import 'package:flutter_terminal_sdk/models/data/dto/transaction_response_turkey.dart';
import 'package:flutter_terminal_sdk/models/data/transaction_response.dart';
import 'package:flutter_terminal_sdk/models/data/authorized_receipt.dart';

typedef VoidCallback = void Function();
typedef StringCallback = void Function(String message);
typedef TransactionResponseCallback = void Function(
    TransactionResponse response);
typedef AuthorizedResponseCallback = void Function(
    AuthorizeReceipt response);
typedef TransactionVoidResponseCallback = void Function(
    TransactionResponseTurkey response);
