// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_terminal_sdk/flutter_terminal_sdk.dart';
import 'package:flutter_terminal_sdk/models/authorized_callbacks.dart';
import 'package:flutter_terminal_sdk/models/card_reader_callbacks.dart';
import 'package:flutter_terminal_sdk/models/data/authorized_receipt.dart';
import 'package:flutter_terminal_sdk/models/data/dto/transaction_response_turkey.dart';
import 'package:flutter_terminal_sdk/models/data/payment_scheme.dart';
import 'package:flutter_terminal_sdk/models/data/transaction_response.dart';
import 'package:flutter_terminal_sdk/models/nearpay_user_response.dart';
import 'package:flutter_terminal_sdk/models/purchase_callbacks.dart';
import 'package:flutter_terminal_sdk/models/purchase_void_callbacks.dart';
import 'package:flutter_terminal_sdk/models/refund_callbacks.dart';
import 'package:flutter_terminal_sdk/models/refund_void_callbacks.dart';
import 'package:flutter_terminal_sdk/models/terminal_connection_response.dart';
import 'package:flutter_terminal_sdk/models/terminal_response.dart';
import 'package:flutter_terminal_sdk/models/transactions_response.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PluginExample());
  }
}

class PluginExample extends StatefulWidget {
  const PluginExample({super.key});

  @override
  _PluginExampleState createState() => _PluginExampleState();
}

class _PluginExampleState extends State<PluginExample> {
  final FlutterTerminalSdk _terminalSdk = FlutterTerminalSdk();

  String _status = "Ready";
  String? transactionUuid;
  String? authTransactionUuid;
  bool? isConnected = false;
  String? refundUuid;
  String? reconcileId;

  final TextEditingController _mobileController =
      TextEditingController(text: "");
  final TextEditingController _emailController =
      TextEditingController(text: "");
  final TextEditingController _otpController = TextEditingController(text: "");
  final TextEditingController _amountController =
      TextEditingController(text: "");
  final TextEditingController _jwtController = TextEditingController(text: "");

  PaymentScheme _selectedScheme = PaymentScheme.VISA;

  NearpayUser? _verifiedUser;

  List<TerminalConnectionModel> _terminals = [];
  List<NearpayUser> _users = [];

  TerminalModel? _connectedTerminal;

  Future<void> _initializeSdk() async {
    try {
      setState(() => _status = "Initializing...");
      await _terminalSdk.initialize(
        environment: Environment.sandbox,
        googleCloudProjectNumber: 0, // Add your google cloud project number
        huaweiSafetyDetectApiKey: "", // Add your huawei safety detect api key
        country: Country.tr,
      );

      setState(() => _status = "SDK Initialized ");
    } catch (e) {
      setState(() => _status = "Error initializing: $e");
    }
  }

  Future<void> _requestPermissions() async {
    try {
      setState(() => _status = "checkRequiredPermissions...");

      var permissions = await _terminalSdk.checkRequiredPermissions();
      String permission = "";
      for (var element in permissions) {
        print("permissions: ${element.permission}, ${element.isGranted}");
        permission = "$permission${element.permission} ${element.isGranted}\n";
      }
      setState(() => _status = "permissions: $permission");
    } catch (e) {
      setState(() => _status = "Error initializing: $e");
    }
  }

  Future<void> _checkWifi() async {
    try {
      setState(() => _status = "checkWifi...");

      var wifi = await _terminalSdk.isWifiEnabled();

      setState(() => _status = "wifi: $wifi");
    } catch (e) {
      setState(() => _status = "Error initializing: $e");
    }
  }

  // check nfc
  Future<void> _checkNfc() async {
    try {
      setState(() => _status = "checkNfc...");

      var nfc = await _terminalSdk.isNfcEnabled();

      setState(() => _status = "nfc: $nfc");
    } catch (e) {
      setState(() => _status = "Error initializing: $e");
    }
  }

  /// Send Mobile OTP
  Future<void> _sendMobileOtp() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final mobile = _mobileController.text;
    if (mobile.isEmpty) {
      setState(() => _status = "Please enter a mobile number");
      return;
    }

    try {
      setState(() => _status = "Sending OTP...");
      await _terminalSdk.sendMobileOtp(mobile);
      setState(() => _status = "OTP sent to $mobile");
    } catch (e) {
      setState(() => _status = "Error sending OTP: $e");
    }
  }

  /// Verify Mobile OTP
  Future<void> _verifyMobileOtp() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final mobile = _mobileController.text.trim();
    final code = _otpController.text.trim();
    if (mobile.isEmpty || code.isEmpty) {
      setState(() => _status = "Please enter mobile number AND OTP code");
      return;
    }

    try {
      setState(() => _status = "Verifying OTP...");
      final user = await _terminalSdk.verifyMobileOtp(
        mobileNumber: mobile,
        code: code,
      );
      setState(() {
        _verifiedUser = user;
        _status =
            "OTP verified! User: ${user.name} \n ${user.mobile} \n ${user.email}";
      });
    } catch (e) {
      setState(() => _status = "Error verifying OTP: $e");
    }
  }

  /// Verify Mobile OTP
  Future<void> _verifyJWT() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final jwt = _jwtController.text.trim();
    if (jwt.isEmpty) {
      setState(() => _status = "Please enter jwt");
      return;
    }

    try {
      setState(() => _status = "Verifying jwt...");
      final terminalModel =
          await _terminalSdk.jwtLogin(jwt: _jwtController.text);

      setState(() {
        _connectedTerminal = terminalModel;
        _status = "jwt verified! terminal: ${terminalModel.toString()}";
        print("jwt verified! terminal: ${terminalModel.toString()}");
      });
    } catch (ex) {
      setState(() => _status = "Error verifying OTP: $ex");
    }
  }

  /// Send Email OTP
  Future<void> _sendEmailOtp() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final email = _emailController.text;
    if (email.isEmpty) {
      setState(() => _status = "Please enter an email address");
      return;
    }

    try {
      setState(() => _status = "Sending OTP...");
      await _terminalSdk.sendEmailOtp(email);
      setState(() => _status = "OTP sent to $email");
    } catch (e) {
      setState(() => _status = "Error sending OTP: $e");
    }
  }

  /// Verify Mobile OTP
  Future<void> _verifyEmailOtp() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final email = _emailController.text.trim();
    final code = _otpController.text.trim();
    if (email.isEmpty || code.isEmpty) {
      setState(() => _status = "Please enter email address AND OTP code");
      return;
    }

    try {
      setState(() => _status = "Verifying OTP...");
      final user = await _terminalSdk.verifyEmailOtp(
        email: email,
        code: code,
      );
      setState(() {
        _verifiedUser = user;
        _status = "OTP verified! User: ${user.name}";
      });
    } catch (e) {
      setState(() => _status = "Error verifying OTP: $e");
    }
  }

  /// get User
  Future<void> _getUser() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "getting user...");
      final user = await _terminalSdk.getUserByUUID(
        uuid: _verifiedUser!.userUUID!,
      );
      setState(() {
        _verifiedUser = user;
        _status = "User: ${user.name} ${user.email} ${user.mobile}";
      });
    } catch (e) {
      setState(() => _status = "$e");
    }
  }

  /// get Users
  Future<void> _getUsers() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "getting user...");
      final listOfUsers = await _terminalSdk.getUsers();
      for (var item in listOfUsers) {
        print(item.name);
      }
      setState(() {
        if (listOfUsers.isNotEmpty) {
          _users = listOfUsers;
          _status = "listOfUsers: ${listOfUsers.length} ";
        } else {
          _status = "No user found";
        }
      });
    } catch (e) {
      setState(() => _status = "$e");
    }
  }

  /// logout
  Future<void> _logout() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "logging out...");
      final message = await _terminalSdk.logout(
        uuid: _verifiedUser!.userUUID!,
      );
      setState(() {
        _verifiedUser = null;
        _status = message;
      });
    } catch (e) {
      setState(() => _status = "$e");
    }
  }

  /// Get Terminals for the verified user
  Future<void> _getTerminals() async {
    if (_verifiedUser == null) {
      setState(() => _status = "No verified user yet");
      return;
    }
    try {
      setState(() => _status = "Fetching terminals...");
      print("_verifiedUser!.userUUID! ${_verifiedUser!.userUUID}");
      final fetchedTerminals = await _terminalSdk
          .getTerminalList(_verifiedUser!.userUUID!, page: 1, pageSize: 10);
      setState(() {
        _terminals = fetchedTerminals;
        _status = "Fetched ${_terminals.length} terminals";
      });
    } catch (e) {
      setState(() => _status = "Error fetching terminals: $e");
    }
  }

  /// Get Terminals for the verified user
  Future<void> _getTerminal() async {
    try {
      if (!_terminalSdk.isInitialized) {
        setState(() => _status = "SDK not initialized yet");
        return;
      }

      if (_connectedTerminal == null) {
        setState(() => _status = "Please connect to a terminal first");
        return;
      }

      print("get Terminal Terminal... ${_connectedTerminal?.terminalUUID}");

      setState(() => _status = "get Terminal Terminal...");
      final fetchedTerminal = await _terminalSdk.getTerminal(
        terminalUUID: _connectedTerminal!.terminalUUID,
      );

      setState(() {
        _connectedTerminal = fetchedTerminal;
        _status =
            "Fetched terminal ${_connectedTerminal?.tid}  = ${_connectedTerminal?.isReady}";
      });
    } catch (e) {
      setState(() => _status = "Error fetching terminal: $e");
    }
  }

  /// Example reverse
  Future<void> _reverse() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    if (transactionUuid == null) {
      setState(() => _status = "No transaction to reverse.");
      return;
    }

    try {
      final reverseResponse =
          await _connectedTerminal!.reverse(transitionId: transactionUuid!);
      setState(() => _status = "reverse Successful! ${reverseResponse.id}");
    } catch (e) {
      setState(() => _status = "Error in reverse: $e");
      return;
    }
  }

  /// Example reverse
  Future<void> _cancel() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    if (transactionUuid == null) {
      setState(() => _status = "No transaction to reverse.");
      return;
    }
    try {
      final cancelResponse =
          await _connectedTerminal!.cancel(transactionUUID: transactionUuid!);

      setState(() => _status = "cancel Successful! $cancelResponse");
    } catch (e) {
      setState(() => _status = "Error in cancel: $e");
      return;
    }
  }

  /// Connect to a specific terminal
  Future<void> _connectToTerminal(TerminalConnectionModel terminal) async {
    if (_verifiedUser == null) {
      setState(() => _status = "No verified user yet");
      return;
    }

    try {
      setState(() => _status =
          "Connecting to terminal ${terminal.name ?? terminal.tid}...");

      print(
          "terminal.tid ${terminal.tid} terminal.uuid ${terminal.uuid} userUUID ${terminal.userUUID}");

      final connectedTerminal = await _terminalSdk.connectTerminal(
        tid: terminal.tid,
        userUUID: terminal.userUUID,
        terminalUUID: terminal.uuid,
      );

      print("connectedTerminal tid ${connectedTerminal.tid}");
      print("connectedTerminal terminalUUID ${connectedTerminal.terminalUUID}");
      setState(() {
        isConnected = true;
        _connectedTerminal = connectedTerminal;
        _status =
            "Connected to TID: ${connectedTerminal.tid}, isReady: ${connectedTerminal.isReady}";
      });
    } catch (e) {
      setState(() => _status = "Error connecting: $e");
    }
  }

  /// Connect to a specific terminal
  Future<void> _connectToTerminal2(
      {required String tid,
      required String userUUID,
      required String terminalUuid}) async {
    // if (_verifiedUser == null) {
    //   setState(() => _status = "No verified user yet");
    //   return;
    // }

    try {
      setState(() => _status = "Connecting to terminal ${tid}...");

      print(
          "terminal.tid ${tid} terminal.uuid ${terminalUuid} userUUID ${userUUID}");

      final connectedTerminal = await _terminalSdk.connectTerminal(
        tid: tid,
        userUUID: userUUID,
        terminalUUID: terminalUuid,
      );

      print("connectedTerminal tid ${connectedTerminal.tid}");
      print("connectedTerminal terminalUUID ${connectedTerminal.terminalUUID}");
      setState(() {
        _connectedTerminal = connectedTerminal;
        _status =
            "Connected to TID: ${connectedTerminal.tid}, isReady: ${connectedTerminal.isReady}";
      });
    } catch (e) {
      setState(() => _status = "Error connecting: $e");
    }
  }

  /// Example purchase
  Future<void> _purchase() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }

    try {
      setState(() => _status = "Purchasing...");

      // Define the callbacks for purchase events
      transactionUuid = const Uuid().v4();

      await _connectedTerminal!.purchase(
        amount: amount,
        // scheme: _selectedScheme,
        callbacks: PurchaseCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReaderDisplayed: () {
              setState(() => _status = "Reader displayed...");
              print("Reader displayed...");
            },
            onReaderClosed: () {
              setState(() => _status = "Reader closed...");
              print("Reader closed...");
            },
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
            },
            onReaderError: (message) {
              print("Reader error: $message");
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
            },
          ),
          onSendTransactionFailure: (message) {
            setState(() => _status = "Transaction failed: $message");
          },
          onSendTransactionCompleted: (TransactionResponse response) {
            _showTransactionDialog(response);
            print(
                "Purchase Successful isApproved:  ${response.events?[0].receipt?.getBKMReceipt().isApproved}");
            print(
                "url qr : ${response.events?[0].receipt?.getBKMReceipt().qrCode}");
            print(
                "Purchase Successful actionCode: ${response.events?[0].receipt?.getBKMReceipt().actionCode}");
            print(
                "Purchase Successful actionCodeMessage:  ${response.events?[0].receipt?.getBKMReceipt().actionCodeMessage?.turkish}");

            setState(() => _status =
                "Purchase Successful! ${response.id} ${response.amountOther} ${response.events?[0].receipt?.getBKMReceipt().id}");
          },
        ),
        transactionUuid: transactionUuid!,
      );
    } catch (e) {
      setState(() => _status = "Error in purchase: $e");
    }
  }

  /// Example purchase
  Future<void> _purchaseVoid() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }

    try {
      setState(() => _status = "Purchasing...");

      // Define the callbacks for purchase events

      print("transactionUuid $transactionUuid");
      await _connectedTerminal!.purchaseVoid(
        amount: amount,
        transactionUuid: transactionUuid!,
        // scheme: _selectedScheme,
        callbacks: PurchaseVoidCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
            },
            onReaderError: (message) {
              print("Reader error: $message");
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
            },
          ),
          onSendTransactionFailure: (message) {
            setState(() => _status = "Transaction failed: $message");
          },
          onSendTransactionCompleted: (response) {
            print(
                "Purchase Void Successful isApproved:  ${response.getBKMReceipt().isApproved}");
            print(
                "Purchase Void Successful response: ${response.getBKMReceipt().toString()}");
            _showVoidTransactionDialog(response);
            setState(() => _status =
                "Purchase Void Successful! ${response.id} ${response.amountOther} ${response.events?[0].receipt}");
          },
        ),
      );
    } catch (e) {
      setState(() => _status = "Error in purchase Void: $e");
    }
  }

  void _showTransactionDialog(TransactionResponse response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transaction Successful"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("ID: ${response.id}"),
                Text(
                    "Is Approved: ${response.events?[0].receipt?.getBKMReceipt().isApproved}"),
                Text(
                    "Action Code: ${response.events?[0].receipt?.getBKMReceipt().actionCode}"),
                Text(
                    "Action Code Message: ${response.events?[0].receipt?.getBKMReceipt().actionCodeMessage?.turkish}"),
                Text(
                    "receipt BKM: ${response.events?[0].receipt?.getBKMReceipt().id ?? 'N/A'}"),
                // Add more fields as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVoidTransactionDialog(TransactionResponseTurkey response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transaction Successful"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("ID: ${response.id}"),
                Text("Is Approved: ${response.getBKMReceipt().isApproved}"),
                Text("Action Code: ${response.getBKMReceipt().actionCode}"),
                Text(
                    "Action Code Message: ${response.getBKMReceipt().actionCodeMessage?.turkish}"),
                Text("receipt BKM: ${response.getBKMReceipt().id ?? 'N/A'}"),
                // Add more fields as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTransactionListDialog(TransactionsResponse response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transaction Successful"),
          content: SingleChildScrollView(
            child: ListBody(
              children: response.data.map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Text("ID: ${e.uuid}"),
                      Text("Scheme: ${e.scheme}"),
                      Text(
                          "Customer Reference Number: ${e.customerReferenceNumber}"),
                      Text("PAN: ${e.pan}"),
                      Text("Amount Authorized: ${e.amountAuthorized}"),
                      Text("Transaction Type: ${e.transactionType}"),
                      Text("Currency: ${e.currency}"),
                      Text("Is Approved: ${e.isApproved}"),
                      Text("Is Reversed: ${e.isReversed}"),
                      Text("Is Reconciled: ${e.isReconciled}"),
                      Text("Start Date: ${e.startDate}"),
                      Text("Start Time: ${e.startTime}"),
                      Text("Performance: ${e.performance}"),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Example refund
  Future<void> _refund() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    // Ensure that you have a valid transactionUuid. This example uses a placeholder.
    if (transactionUuid == null) {
      setState(() => _status = "No transaction to refund.");
      return;
    }
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount for refund.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }
    try {
      refundUuid = const Uuid().v4();

      setState(() => _status = "Refunding...");
      final result = await _connectedTerminal?.refund(
        refundUuid: refundUuid!,
        transactionUuid: transactionUuid!,
        amount: amount,
        scheme: _selectedScheme,
        callbacks: RefundCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
            },
            onReaderError: (message) {
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
            },
          ),
          onSendTransactionCompleted: (response) {
            _showTransactionDialog(response);
            setState(() => _status =
                "Refund Successful! ${response.id} ${response.amountOther} ${response.events?[0].receipt?.getBKMReceipt().id}");
          },
          onSendTransactionFailure: (message) {
            setState(() => _status = "Refund failed: $message");
          },
        ),
      );
      setState(() => _status = "Refund Successful: ${result.toString()}");
    } catch (e) {
      setState(() => _status = "Error in refund: $e");
    }
  }

  /// Example refund
  Future<void> _refundVoid() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    // Ensure that you have a valid transactionUuid. This example uses a placeholder.
    if (transactionUuid == null) {
      setState(() => _status = "No transaction to refund.");
      return;
    }
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount for refund.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }
    try {
      setState(() => _status = "Refunding...");
      final result = await _connectedTerminal?.refundVoid(
        refundUuid: refundUuid!,
        amount: amount,
        scheme: _selectedScheme,
        callbacks: RefundVoidCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
            },
            onReaderError: (message) {
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
            },
          ),
          onSendTransactionCompleted: (response) {
            setState(() => _status =
                "Refund Successful! ${response.id} ${response.amountOther} ${response.events?[0].receipt}");
          },
          onSendTransactionFailure: (message) {
            setState(() => _status = "Refund failed: $message");
          },
        ),
      );
      setState(() => _status = "Refund Successful: ${result.toString()}");
    } catch (e) {
      setState(() => _status = "Error in refund: $e");
    }
  }

  /// Example getTransactionDetails
  Future<void> _getTransactionDetails() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    // Ensure that you have a valid transactionUuid. This example uses a placeholder.
    if (transactionUuid == null) {
      setState(() => _status = "No transaction to get details.");
      return;
    }

    try {
      setState(() => _status = "GetTransaction...");
      final result = await _connectedTerminal?.getTransactionDetails(
        transactionUuid: transactionUuid!,
      );

      setState(() =>
          _status = "GetTransaction Successful: ${result?.receipts![0].id}");
    } catch (e) {
      setState(() => _status = "Error in getTransaction: $e");
    }
  }

  /// Example get Transaction List
  Future<void> _getTransactionList() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "GetTransactionList...");
      final result = await _connectedTerminal?.getTransactionsList(
        page: 1,
        pageSize: 10,
      );
      _showTransactionListDialog(result!);

      setState(() => _status = "GetTransactions Successful: ${result}");
    } catch (e) {
      setState(() => _status = "Error in getTransactions: $e");
    }
  }

  /// get Reconciliation list
  Future<void> _getReconciliationList() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "GetReconciliationList...");
      final result = await _connectedTerminal?.getReconcileList(
        page: 1,
        pageSize: 10,
      );
      setState(() =>
          _status = "GetReconciliation Successful: ${result?.data[0].id}");
    } catch (e) {
      setState(() => _status = "Error in getReconciliation: $e");
    }
  }

  /// get Reconcile details
  Future<void> _getReconcileDetails() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (reconcileId == null) {
      setState(() => _status = "No reconcileId to get details.");
      return;
    }

    try {
      setState(() => _status = "GetReconciliation...");
      final result = await _connectedTerminal?.getReconcileDetails(
          uuid: reconcileId ?? "");
      setState(() => _status = "GetReconciliation Successful: ${result?.id}");
    } catch (e) {
      setState(() => _status = "Error in GetReconciliation: $e");
    }
  }

  /// reconcile
  Future<void> _reconcile() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "Reconcile...");
      final result = await _connectedTerminal?.reconcile();
      reconcileId = result?.receipt?.reconciliation?.id;
      setState(() => _status = "Reconcile Successful: ${result.toString()}");
    } catch (e) {
      setState(() => _status = "Error in Reconcile: $e");
    }
  }

  /// Builds a list view of available terminals
  Widget _buildTerminalsList() {
    if (_terminals.isEmpty) {
      return const Text("No terminals fetched yet.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Prevent inner scrolling
      itemCount: _terminals.length,
      itemBuilder: (context, index) {
        final terminal = _terminals[index];
        return Card(
          child: ListTile(
            title: Text(terminal.name ?? "Unnamed Terminal"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("TID: ${terminal.tid}"),
                Text("UUID: ${terminal.uuid}"),
              ],
            ),
            onTap: () => _connectToTerminal(terminal),
          ),
        );
      },
    );
  }

  /// Builds a list view of available terminals
  Widget _buildUserList() {
    if (_users.isEmpty) {
      return const Text("No users fetched yet.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Prevent inner scrolling
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          child: ListTile(
            title: Text(user.name ?? "Unnamed Terminal"),
            subtitle: Text("mail: ${user.email} \n mobile: ${user.mobile}"),
            onTap: () {
              print("user.uuid ${user.userUUID}");
              setState(() {
                _verifiedUser = user;
              });
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // _terminalSdk.dispose();
    _connectedTerminal?.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Terminal SDK Example"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Status: $_status", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          print("Initializing SDK start");
                          await _initializeSdk();
                          print("Initializing SDK end");
                        },
                        child: const Text("Initialize SDK"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _requestPermissions,
                        child: const Text("Check Permission"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _checkNfc,
                        child: const Text("Check NFC"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _checkWifi,
                        child: const Text("Check WIFI"),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Mobile Number",
                          hintText: "+966xxxxxxxxx",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _sendMobileOtp,
                        child: const Text("Send Mobile OTP"),
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email Address",
                          hintText: "email@x.com",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _sendEmailOtp,
                        child: const Text("Send Email OTP"),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "OTP Code",
                          hintText: "1234",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _verifyMobileOtp,
                        child: const Text("Verify Mobile OTP"),
                      ),
                      ElevatedButton(
                        onPressed: _verifyEmailOtp,
                        child: const Text("Verify Email OTP"),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _jwtController,
                        decoration: const InputDecoration(
                          labelText: "jwt",
                          hintText: "342FDSF234WEFSADF",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _verifyJWT,
                        child: const Text("Verify JWT"),
                      ),
                      ElevatedButton(
                        onPressed: _getTerminal,
                        child: const Text("Get Terminal by TID"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _connectToTerminal2(
                              tid: 'I1UY5FSS',
                              userUUID: 'c4125f58-ef99-40dc-a4c5-347b0fd3cb55',
                              terminalUuid:
                                  '93a03239-6b2c-4752-8e01-5666e02b3278');
                        },
                        child: const Text("connect To Termin"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getUsers,
                        child: const Text("Get Users"),
                      ),
                      const SizedBox(height: 20),
                      _buildUserList(),
                      const SizedBox(height: 20),
                      // Only show "Get Terminals" if we have a verified user
                      if (_verifiedUser != null) ...[
                        ElevatedButton(
                          onPressed: _getUser,
                          child: const Text("Get User"),
                        ),
                        ElevatedButton(
                          onPressed: _logout,
                          child: const Text("logout"),
                        ),
                        ElevatedButton(
                          onPressed: _getTerminals,
                          child: const Text("Get Terminals"),
                        ),
                        const SizedBox(height: 20),
                        // Display the terminals list
                        _buildTerminalsList(),
                        const SizedBox(height: 20),
                        isConnected == true
                            ? Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      authTransactionUuid = const Uuid().v4();
                                      if (_connectedTerminal != null) {
                                        _connectedTerminal!.authorize(
                                          uuid: authTransactionUuid ?? "",
                                          amount: 1000,
                                          callbacks: AuthorizedCallbacks(
                                            cardReaderCallbacks:
                                                CardReaderCallbacks(
                                              onReaderDisplayed: () {
                                                setState(() => _status =
                                                    "Reader displayed...");
                                                print("Reader displayed...");
                                              },
                                              onReaderClosed: () {
                                                setState(() => _status =
                                                    "Reader closed...");
                                                print("Reader closed...");
                                              },
                                              onReadingStarted: () {
                                                setState(() => _status =
                                                    "Reading started...");
                                              },
                                              onReaderWaiting: () {
                                                setState(() => _status =
                                                    "Reader waiting...");
                                              },
                                              onReaderReading: () {
                                                setState(() => _status =
                                                    "Reader reading...");
                                              },
                                              onReaderRetry: () {
                                                setState(() => _status =
                                                    "Reader retrying...");
                                              },
                                              onPinEntering: () {
                                                setState(() => _status =
                                                    "Entering PIN...");
                                              },
                                              onReaderFinished: () {
                                                setState(() => _status =
                                                    "Reader finished.");
                                              },
                                              onReaderError: (message) {
                                                print("Reader error: $message");
                                                setState(() => _status =
                                                    "Reader error: $message");
                                              },
                                              onCardReadSuccess: () {
                                                setState(() => _status =
                                                    "Card read successfully.");
                                              },
                                              onCardReadFailure: (message) {
                                                setState(() => _status =
                                                    "Card read failure: $message");
                                              },
                                            ),
                                            onSendTransactionFailure:
                                                (message) {
                                              setState(() => _status =
                                                  "Transaction failed: $message");
                                            },
                                            onSendAuthorizedCompleted:
                                                (AuthorizeReceipt response) {
                                              print(
                                                  "Authorize Successful isApproved:  ${response.events[0].receipt?.data.status}");
                                              setState(() => _status =
                                                  "Authorize Successful! ${response.id} ${response.amountOther} ${response.events[0].receipt?.data.status}");
                                            },
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                        "Authorize ${_connectedTerminal?.tid}"),
                                  ),
                                  authTransactionUuid != null
                                      ? ElevatedButton(
                                          onPressed: () {
                                            if (_connectedTerminal != null) {
                                              try {
                                                var voidInfo = _connectedTerminal!
                                                    .authorizeVoid(
                                                        id: authTransactionUuid ??
                                                            "");
                                                setState(() => _status =
                                                    "authorizeVoid Successful: ${voidInfo.toString()}");
                                              } catch (e) {
                                                setState(() => _status =
                                                    "Error in authorizeVoid: $e");
                                              }
                                            }
                                          },
                                          child: Text(
                                              "voidAuthorization ${_connectedTerminal?.tid}"))
                                      : const SizedBox(),
                                  authTransactionUuid != null
                                      ? ElevatedButton(
                                          onPressed: () {
                                            if (_connectedTerminal != null) {
                                              _connectedTerminal!
                                                  .incrementAuthorization(
                                                uuid: const Uuid().v4(),
                                                authorizationUuid:
                                                    authTransactionUuid ?? "",
                                                amount: 2000,
                                              );
                                            }
                                          },
                                          child: Text(
                                              "incrementAuthorization ${_connectedTerminal?.tid}"),
                                        )
                                      : const SizedBox(),
                                  authTransactionUuid != null
                                      ? ElevatedButton(
                                          onPressed: () {
                                            if (_connectedTerminal != null) {
                                              _connectedTerminal!
                                                  .captureAuthorization(
                                                authorizationUuid:
                                                    authTransactionUuid ?? "",
                                                amount: 3000,
                                                uuid: const Uuid().v4(),
                                              );
                                            }
                                          },
                                          child: Text(
                                              "captureAuthorization ${_connectedTerminal?.tid}"))
                                      : const SizedBox(),
                                ],
                              )
                            : const Text("Not connected to any terminal"),
                        const SizedBox(height: 20),
                      ],

                      // Purchase inputs
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number, // Correct placement
                        decoration: const InputDecoration(
                          labelText: "Amount",
                          hintText: "5000",
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<PaymentScheme>(
                        decoration: const InputDecoration(
                          labelText: "Payment Scheme",
                        ),
                        value: _selectedScheme,
                        items: PaymentScheme.values.map((PaymentScheme value) {
                          return DropdownMenuItem<PaymentScheme>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedScheme = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _purchase,
                        child: const Text("Purchase"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _purchaseVoid,
                        child: const Text("PurchaseVoid"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _refund,
                        child: const Text("Refund"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _refundVoid,
                        child: const Text("RefundVoid"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _reverse,
                        child: const Text("Reverse"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _cancel,
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getTransactionDetails,
                        child: const Text("Get Transaction Details"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getTransactionList,
                        child: const Text("Get Transaction List"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getReconciliationList,
                        child: const Text("Get Reconciliation List"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getReconcileDetails,
                        child: const Text("Get Reconciliation Details"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _reconcile,
                        child: const Text("Reconcile"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
