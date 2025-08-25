import 'callbacks.dart';
import 'card_reader_callbacks.dart';

class PurchaseVoidCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final StringCallback? onSendTransactionFailure;
  final TransactionVoidResponseCallback? onSendTransactionCompleted;

  PurchaseVoidCallbacks({
    this.cardReaderCallbacks,
    this.onSendTransactionFailure,
    this.onSendTransactionCompleted,
  });
}