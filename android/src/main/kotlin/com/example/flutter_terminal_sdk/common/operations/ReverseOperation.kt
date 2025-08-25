// android/src/main/kotlin/com/example/flutter_terminal_sdk/common/operations/PurchaseOperation.kt

package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.google.gson.Gson
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.TransactionResponse
import io.nearpay.terminalsdk.listeners.ReverseTransactionListener
import io.nearpay.terminalsdk.listeners.failures.ReverseTransactionFailure
import timber.log.Timber

class ReverseOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        // Extract required arguments
        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))
        // Extract required arguments
        val transitionId = filter.getString("transitionId")
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
            terminal.reverseTransaction(
                transactionUUID = transitionId,
                reverseTransactionListener = object : ReverseTransactionListener {


                    override fun onReverseTransactionFailure(reverseTransactionFailure: ReverseTransactionFailure) {
                        Timber.tag("onReverseFailure")
                            .d("Reverse failed $reverseTransactionFailure")
                        response(
                            ResponseHandler.error(
                                "Reverse Failure",
                                reverseTransactionFailure.toString()
                            )
                        )
                    }

                    override fun onReverseTransactionCompleted(transactionResponse: TransactionResponse) {
                        val jsonString = gson.toJson(transactionResponse)
                        val map = gson.fromJson(jsonString, Map::class.java) as Map<String, Any>
                        response(ResponseHandler.success("Reverse Success", map))
                    }
                })
        } catch (e: Exception) {
            // Handle any unexpected exceptions during purchase
            response(ResponseHandler.error("REVERSE_FAILED", "Reverse failed: ${e.message}"))
        }
    }

}
