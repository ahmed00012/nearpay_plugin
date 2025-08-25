import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.operations.AuthorizeOperation
import com.example.flutter_terminal_sdk.common.operations.VoidAuthorizationOperation
import com.example.flutter_terminal_sdk.common.operations.BaseOperation
import com.example.flutter_terminal_sdk.common.operations.CancelOperation
import com.example.flutter_terminal_sdk.common.operations.CaptureAuthorizationOperation
import com.example.flutter_terminal_sdk.common.operations.CheckRequiredPermissionsOperation
import com.example.flutter_terminal_sdk.common.operations.ConnectTerminalOperation
import com.example.flutter_terminal_sdk.common.operations.GetReconcileDetailsOperation
import com.example.flutter_terminal_sdk.common.operations.GetReconcileListOperation
import com.example.flutter_terminal_sdk.common.operations.GetTerminalListOperation
import com.example.flutter_terminal_sdk.common.operations.GetTerminalOperation
import com.example.flutter_terminal_sdk.common.operations.GetTransactionDetailsOperation
import com.example.flutter_terminal_sdk.common.operations.GetTransactionsListOperation
import com.example.flutter_terminal_sdk.common.operations.GetUserOperation
import com.example.flutter_terminal_sdk.common.operations.GetUsersOperation
import com.example.flutter_terminal_sdk.common.operations.IncrementAuthorizationOperation
import com.example.flutter_terminal_sdk.common.operations.InitializeOperation
import com.example.flutter_terminal_sdk.common.operations.IsNfcEnableOperation
import com.example.flutter_terminal_sdk.common.operations.IsWifiEnableOperation
import com.example.flutter_terminal_sdk.common.operations.PurchaseOperation
import com.example.flutter_terminal_sdk.common.operations.PurchaseVoidOperation
import com.example.flutter_terminal_sdk.common.operations.ReconcileOperation
import com.example.flutter_terminal_sdk.common.operations.RefundOperation
import com.example.flutter_terminal_sdk.common.operations.RefundVoidOperation
import com.example.flutter_terminal_sdk.common.operations.ReverseOperation
import com.example.flutter_terminal_sdk.common.operations.SendEmailOtpOperation
import com.example.flutter_terminal_sdk.common.operations.SendMobileOtpOperation
import com.example.flutter_terminal_sdk.common.operations.VerifyEmailOtpOperation
import com.example.flutter_terminal_sdk.common.operations.VerifyJWTOperation
import com.example.flutter_terminal_sdk.common.operations.VerifyMobileOtpOperation
import com.example.flutter_terminal_sdk.common.operations.logoutOperation

class NearpayOperatorFactory(private val provider: NearpayProvider) {
    private val operations: Map<String, BaseOperation> = mapOf(
        "initialize" to InitializeOperation(provider),
        "sendMobileOtp" to SendMobileOtpOperation(provider),
        "sendEmailOtp" to SendEmailOtpOperation(provider),
        "verifyMobileOtp" to VerifyMobileOtpOperation(provider),
        "verifyEmailOtp" to VerifyEmailOtpOperation(provider),
        "purchase" to PurchaseOperation(provider),
        "purchaseVoid" to PurchaseVoidOperation(provider),
        "refund" to RefundOperation(provider),
        "refundVoid" to RefundVoidOperation(provider),
        "getTerminalList" to GetTerminalListOperation(provider),
        "connectTerminal" to ConnectTerminalOperation(provider),
        "getTransactionDetails" to GetTransactionDetailsOperation(provider),
        "getTransactionsList" to GetTransactionsListOperation(provider),
        "getReconcileList" to GetReconcileListOperation(provider),
        "getReconcileDetails" to GetReconcileDetailsOperation(provider),
        "reconcile" to ReconcileOperation(provider),
        "getUser" to GetUserOperation(provider),
        "getUsers" to GetUsersOperation(provider),
        "logout" to logoutOperation(provider),
        "getTerminal" to GetTerminalOperation(provider),
        "jwtVerify" to VerifyJWTOperation(provider),
        "reverse" to ReverseOperation(provider),
        "cancel" to CancelOperation(provider),
        "checkRequiredPermissions" to CheckRequiredPermissionsOperation(provider),
        "isWifiEnabled" to IsWifiEnableOperation(provider),
        "isNfcEnabled" to IsNfcEnableOperation(provider),
        "authorize" to AuthorizeOperation(provider),
        "captureAuthorization" to CaptureAuthorizationOperation(provider),
        "authorizeVoid" to VoidAuthorizationOperation(provider),
        "incrementAuthorization" to IncrementAuthorizationOperation(provider) // Assuming incrementalAuthorize is similar to authorize

    )

    fun getOperation(method: String): BaseOperation? {
        return operations[method]
    }
}