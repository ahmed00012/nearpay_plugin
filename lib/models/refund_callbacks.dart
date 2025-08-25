import 'callbacks.dart';
import 'card_reader_callbacks.dart';


class RefundCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final StringCallback? onSendTransactionFailure;
  final TransactionResponseCallback? onSendTransactionCompleted;

  RefundCallbacks({
    this.cardReaderCallbacks,
    this.onSendTransactionFailure,
    this.onSendTransactionCompleted,
  });
}