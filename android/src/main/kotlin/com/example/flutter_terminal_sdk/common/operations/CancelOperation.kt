// android/src/main/kotlin/com/example/flutter_terminal_sdk/common/operations/PurchaseOperation.kt

package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.google.gson.Gson
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.CanceledState
import io.nearpay.terminalsdk.listeners.CancelTransactionListener
import io.nearpay.terminalsdk.listeners.failures.CancelTransactionFailure
import timber.log.Timber

class CancelOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        // Extract required arguments
        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))
        // Extract required arguments
        val transactionUUID = filter.getString("transactionUUID")
            ?: return response(
                ResponseHandler.error(
                    "MISSING_TransitionId",
                    "Transition Id is required"
                )
            )


        // Retrieve the TerminalSDK instance
        val terminal: Terminal =
            provider.terminalSdk?.getTerminal(provider.activity!!, terminalUUID)
                ?: return response(
                    ResponseHandler.error(
                        "TERMINAL_NOT_FOUND",
                        "Terminal with uuid = $terminalUUID = not found"
                    )
                )
        Timber.d("Got Terminal successfully")
        try {
            // Initiate the purchase process
            terminal.cancelTransaction(
                transactionUUID = transactionUUID,
                cancelTransactionListener = object : CancelTransactionListener {

                    override fun onCancelTransactionFailure(cancelTransactionFailure: CancelTransactionFailure) {
                        Timber.tag("onCancelFailure")
                            .d("Cancel failed $cancelTransactionFailure")
                        response(
                            ResponseHandler.error(
                                "Cancel Failure",
                                cancelTransactionFailure.toString()
                            )
                        )
                    }

                    override fun onCancelTransactionSuccess(canceledState: CanceledState) {
                        val jsonString = gson.toJson(canceledState)
                        val map = gson.fromJson(jsonString, Map::class.java) as Map<String, Any>
                        response(
                            ResponseHandler.success(
                                "Cancel Success",
                                map
                            )
                        )
                    }

                })
        } catch (e: Exception) {
            // Handle any unexpected exceptions during purchase
            response(ResponseHandler.error("CANCEL_FAILED", "Cancel failed: ${e.message}"))
        }
    }

}
