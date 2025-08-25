package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.google.gson.Gson
import timber.log.Timber

class IsWifiEnableOperation(provider: NearpayProvider) : BaseOperation(provider) {

    //gson
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        var isEnable = provider.isWifiEnabled() ?: return response(
            ResponseHandler.error("INVALID_REQUEST", "Not able to get wifi status")
        ) // return List<PermissionStatus>

        Timber.d("Wifi: $isEnable")




        response(ResponseHandler.success("Get Wifi status successfully", isEnable))

    }
}
