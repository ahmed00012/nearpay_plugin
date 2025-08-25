package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import timber.log.Timber

class IsNfcEnableOperation(provider: NearpayProvider) : BaseOperation(provider) {

    //gson
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        var isEnable = provider.isNfcEnabled() ?: return response(
            ResponseHandler.error("INVALID_REQUEST", "Not able to get NFC status")
        ) // return List<PermissionStatus>

        Timber.d("Nfc: $isEnable")


        response(ResponseHandler.success("Get NFC status successfully", isEnable))

    }
}
