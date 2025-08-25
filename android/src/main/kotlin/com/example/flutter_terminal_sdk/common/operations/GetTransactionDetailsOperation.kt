package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.google.gson.Gson
import io.nearpay.terminalsdk.data.dto.ReceiptsResponse
import io.nearpay.terminalsdk.data.dto.ReceiptsResponseTurkey
import io.nearpay.terminalsdk.listeners.GetTransactionListener
import io.nearpay.terminalsdk.listeners.failures.GetTransactionFailure
import timber.log.Timber

class GetTransactionDetailsOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val transactionUUID = filter.getString("transactionUUID") ?: return response(
            ResponseHandler.error("MISSING_TRANSACTION_UUID", "Transaction UUID is required")
        )


        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }

        terminal?.getTransaction(uuid = transactionUUID,
            getTransactionListener = object : GetTransactionListener {

                override fun onGetTransactionFailure(error: GetTransactionFailure) {
                    Timber.tag("handleReadCard").d("GetTransactionFailure failed $error")
                    response(
                        ResponseHandler.error(
                            "GET_TRANSACTION_FAILURE", error.toString()
                        )
                    )
                }

                override fun onGetTransactionSuccess(transaction: ReceiptsResponse) {
                    val jsonString = gson.toJson(transaction)
                    val map = gson.fromJson(jsonString, Map::class.java) as Map<String, Any>
                    Timber.tag("handleReadCard").d("GetTransactionSuccess transaction $transaction")
                    response(
                        ResponseHandler.success(
                            "Transaction details fetched successfully",
                            map
                        )
                    )
                }

            }

        )

    }

}