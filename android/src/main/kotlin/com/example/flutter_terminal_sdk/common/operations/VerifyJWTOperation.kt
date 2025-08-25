package com.example.flutter_terminal_sdk.common.operations


import android.util.Log
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.JWTLoginData
import io.nearpay.terminalsdk.listeners.JWTLoginListener
import io.nearpay.terminalsdk.listeners.failures.JWTLoginFailure
import timber.log.Timber


class VerifyJWTOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val jwt = filter.getString("jwt") ?: return response(
            ResponseHandler.error("MISSING_MOBILE", "jwt is required")
        )

        val loginData = JWTLoginData(
            jwt = jwt,
        )
        provider.terminalSdk?.jwtLogin(loginData, object : JWTLoginListener {

            override fun onJWTLoginSuccess(terminal: Terminal) {

                Timber.tag("jwtLoginSuccess")
                    .d("terminalUUID ${terminal.terminalUUID} tid :  ${terminal.tid} name : ${terminal.name}")


                val resultData = mapOf(
                    "tid" to terminal.tid,
                    "isReady" to terminal.isTerminalReady(),
                    "terminalUUID" to terminal.terminalUUID,
                    "uuid" to terminal.terminalUUID,
                    "name" to terminal.name,
                )
                response(
                    ResponseHandler.success(
                        "Login successful: ${terminal.terminalUUID}",
                        resultData
                    )
                )


            }

            override fun onJWTLoginFailure(jwtLoginFailure: JWTLoginFailure) {
                val errorMessage = (jwtLoginFailure as JWTLoginFailure.LoginFailure).message
                Timber.tag("errorMessage").d("$errorMessage")
                response(ResponseHandler.error("VERIFY_FAILURE", errorMessage.toString()))
            }
        })
    }
}