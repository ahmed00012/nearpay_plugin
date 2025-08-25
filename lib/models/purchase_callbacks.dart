import 'callbacks.dart';
import 'card_reader_callbacks.dart';

class PurchaseCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final StringCallback? onSendTransactionFailure;
  final TransactionResponseCallback? onSendTransactionCompleted;

  PurchaseCallbacks({
    this.cardReaderCallbacks,
    this.onSendTransactionFailure,
    this.onSendTransactionCompleted,
  });
}