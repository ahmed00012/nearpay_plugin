package com.example.flutter_terminal_sdk.common.operations

import io.nearpay.terminalsdk.listeners.failures.RefundTransactionFailure
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import io.nearpay.terminalsdk.data.dto.PaymentScheme
import io.nearpay.terminalsdk.data.dto.TransactionResponseTurkey
import io.nearpay.terminalsdk.listeners.ReadCardListener
import io.nearpay.terminalsdk.listeners.RefundVoidListener
import io.nearpay.terminalsdk.listeners.failures.ReadCardFailure
import timber.log.Timber

class RefundVoidOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val refundUuid = filter.getString("refundUuid") ?: return response(
            ResponseHandler.error("MISSING_REFUND_UUID", "Refund UUID is required")
        )
        val amount = filter.getLong("amount") ?: return response(
            ResponseHandler.error("MISSING_AMOUNT", "Amount is required")
        )

        val customerReferenceNumber = filter.getString("customerReferenceNumber")

        val schemeString = filter.getString("scheme")
        val scheme = schemeString?.uppercase()?.let { PaymentScheme.valueOf(it) }

        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }


        terminal?.refundVoid(
            amount = amount,
            transactionUUID = refundUuid,
            scheme = scheme,
            customerReferenceNumber = customerReferenceNumber,
            readCardListener = object : ReadCardListener {
                override fun onReaderClosed() {
                    Timber.tag("RefundVoidOperation").d("onReaderClosed")
                    sendRefundEvent(refundUuid, "readerClosed", null, null)
                }

                override fun onReaderDisplayed() {
                    Timber.tag("RefundVoidOperation").d("onReaderDisplayed")
                    sendRefundEvent(refundUuid, "readerDisplayed", null, null)

                }

                override fun onReadCardSuccess() {
                    Timber.tag("RefundOperation").d("onReadCardSuccess")
                    sendRefundEvent(
                        refundUuid, "cardReadSuccess", "Card read successfully", null
                    )
                }

                override fun onReadCardFailure(readCardFailure: ReadCardFailure) {
                    Timber.tag("RefundOperation").d("onReadCardFailure $readCardFailure")
                    sendRefundEvent(
                        refundUuid, "cardReadFailure", readCardFailure.toString(), null
                    )

                }

                override fun onReaderWaiting() {
                    Timber.tag("RefundOperation").d("onReaderWaiting")
                    sendRefundEvent(refundUuid, "readerWaiting", null, null)
                }

                override fun onReaderReading() {
                    Timber.tag("RefundOperation").d("onReaderReading")
                    sendRefundEvent(refundUuid, "readerReading", null, null)
                }

                override fun onReaderRetry() {
                    Timber.tag("RefundOperation").d("onReaderRetry")
                    sendRefundEvent(refundUuid, "readerRetry", null, null)
                }

                override fun onPinEntering() {
                    Timber.tag("RefundOperation").d("onPinEntering")
                    sendRefundEvent(refundUuid, "pinEntering", null, null)
                }

                override fun onReaderFinished() {
                    Timber.tag("RefundOperation").d("onReaderFinished")
                    sendRefundEvent(refundUuid, "readerFinished", null, null)
                }

                override fun onReaderError(error: String?) {
                    Timber.tag("RefundOperation").d("onReaderError $error")
                    sendRefundEvent(
                        refundUuid, "readerError", error ?: "Unknown reader error", null
                    )
                }

                override fun onReadingStarted() {
                    Timber.tag("RefundOperation").d("onReadingStarted")
                    sendRefundEvent(refundUuid, "readingStarted", null, null)
                }
            },
            refundVoidListener = object :

                RefundVoidListener {
                override fun onRefundVoidCompleted(purchaseVoidResponse: TransactionResponseTurkey) {
                    Timber.tag("onRefundVoidSuccess").d("onRefundVoidSuccess $purchaseVoidResponse")
                    val jsonString = gson.toJson(purchaseVoidResponse)
                    val map: Map<String, Any> =
                        gson.fromJson(jsonString, object : TypeToken<Map<String, Any>>() {}.type)
                    sendRefundEvent(refundUuid, "sendTransactionVoidCompleted", null, map)

                }



                override fun onRefundVoidFailure(refundTransactionFailure: RefundTransactionFailure) {
                    Timber.tag("onRefundVoidFailure")
                        .d("onRefundVoidFailure $refundTransactionFailure")
                    sendRefundEvent(
                        refundUuid,
                        "sendTransactionFailure",
                        refundTransactionFailure.toString(),
                        null
                    )
                }


            })
    }

    private fun sendRefundEvent(
        transactionUuid: String, eventType: String, message: String?, data: Any?
    ) {
        val eventArgs = mutableMapOf<String, Any>(
            "transactionUuid" to transactionUuid, "type" to eventType
        )
        message?.let { eventArgs["message"] = it }
        data?.let { eventArgs["data"] = it }

        try {
            provider.methodChannel.invokeMethod("refundVoidEvent", eventArgs)
        } catch (e: Exception) {
            // Log the error but do not disrupt the refund flow
            Timber.e(
                e,
                "Failed to send refund void event: $eventType for transactionUuid: $transactionUuid"
            )
        }
    }
}