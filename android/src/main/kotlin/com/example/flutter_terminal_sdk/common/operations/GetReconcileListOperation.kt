package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.google.gson.Gson
import io.nearpay.terminalsdk.data.dto.ReconciliationListResponse
import io.nearpay.terminalsdk.listeners.GetReconciliationListListener
import io.nearpay.terminalsdk.listeners.failures.GetReconciliationListFailure

class GetReconcileListOperation(provider: NearpayProvider) : BaseOperation(provider) {

    private val gson = Gson()
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val page = filter.getInt("page")
        val pageSize = filter.getInt("pageSize")
        val startDate = filter.getLong("startDate")
        val endDate = filter.getLong("endDate")


        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }

        terminal?.getReconciliationList(
            page = page,
            pageSize = pageSize,
            startDate = startDate,
            endDate = endDate,
            getReconciliationListListener = object : GetReconciliationListListener {

                override fun onGetReconciliationListFailure(error: GetReconciliationListFailure) {
                    response(ResponseHandler.error("GetReconciliationList", error.toString()))

                }

                override fun onGetReconciliationListSuccess(reconciliationListResponse: ReconciliationListResponse) {
                    val jsonString = gson.toJson(reconciliationListResponse)
                    val map = gson.fromJson(jsonString, Map::class.java) as Map<String, Any>
                     response(ResponseHandler.success("GetReconciliationList", map))
                }


            }
        )
    }

//    private fun sendReconciliationListEvent(
//        eventType: String,
//        message: String?,
//        data: Any?
//    ) {
//        val eventArgs = mutableMapOf<String, Any>(
//            "type" to eventType
//        )
//        message?.let { eventArgs["message"] = it }
//        data?.let { eventArgs["data"] = it }
//
//        try {
//            provider.methodChannel.invokeMethod("getReconcileListEvent", eventArgs)
//        } catch (e: Exception) {
//            // Log the error but do not disrupt the refund flow
//            Timber.e(
//                e,
//                "Failed to send get transactions details event: $eventType"
//            )
//        }
//    }
}