import 'callbacks.dart';
import 'card_reader_callbacks.dart';


class RefundVoidCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final StringCallback? onSendTransactionFailure;
  final TransactionVoidResponseCallback? onSendTransactionCompleted;

  RefundVoidCallbacks({
    this.cardReaderCallbacks,
    this.onSendTransactionFailure,
    this.onSendTransactionCompleted,
  });
}