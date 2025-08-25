package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.google.gson.Gson
import io.nearpay.terminalsdk.data.dto.TransactionsResponse
import io.nearpay.terminalsdk.listeners.GetTransactionsListListener
import io.nearpay.terminalsdk.listeners.failures.GetTransactionsListFailure
import timber.log.Timber

class GetTransactionsListOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val page = filter.getInt("page")
        val pageSize = filter.getInt("pageSize")
        val isReconciled = filter.getBoolean("isReconciled")
        val date = filter.getLong("date")
        val startDate = filter.getLong("startDate")
        val endDate = filter.getLong("endDate")
        val customerReferenceNumber = filter.getString("customerReferenceNumber")
        Timber.tag("GetTransactionListOperation").d(
            "terminalUUID: $terminalUUID, page: $page, pageSize: $pageSize, isReconciled: $isReconciled, date: $date, startDate: $startDate, endDate: $endDate, customerReferenceNumber: $customerReferenceNumber"
        )

        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }

        terminal?.getTransactionsList(page = page,
            pageSize = pageSize,
            isReconciled = isReconciled,
            date = date,
            startDate = startDate,
            endDate = endDate,
            customerReferenceNumber = customerReferenceNumber,
            getTransactionsListListener = object : GetTransactionsListListener {
                override fun onGetTransactionsListSuccess(transactionsList: TransactionsResponse) {
                    val jsonString = gson.toJson(transactionsList)
                    val map = gson.fromJson(jsonString, Map::class.java) as Map<String, Any>

                    Timber.tag("GetTransactionListOperation")
                        .d("GetTransactionListSuccess map $map")
                    response(
                        ResponseHandler.success(
                            "Transaction list fetched successfully",
                            map
                        )
                    )
                }

                override fun onGetTransactionsListFailure(error: GetTransactionsListFailure) {
                    Timber.tag("GetTransactionListOperation")
                        .d("GetTransactionListFailure failed $error")
                    response(
                        ResponseHandler.error(
                            "GET_TRANSACTION_LIST_FAILURE", error.toString()
                        )
                    )

                }


            })
    }

}