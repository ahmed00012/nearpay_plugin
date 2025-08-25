package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler

class logoutOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val uuid = filter.getString("uuid") ?: return response(
            ResponseHandler.error("MISSING_UUID", "UUID is required")
        )

        provider.terminalSdk?.logout(uuid) ?: return response(
            ResponseHandler.error("INVALID_USER", "No user found for UUID: $uuid")
        )


        response(ResponseHandler.success("User logout successfully", null))

    }
}
