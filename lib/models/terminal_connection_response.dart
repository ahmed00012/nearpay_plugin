import 'package:flutter_terminal_sdk/models/terminal_response.dart';

import '../errors/errors.dart';
import '../flutter_terminal_sdk.dart';

class TerminalConnectionModel {
  final String? name;
  final String tid;
  final String uuid;
  final bool busy;
  final String mode;
  final bool isLocked;
  final bool hasProfile;
  final String userUUID;

  TerminalConnectionModel({
    this.name,
    required this.tid,
    required this.uuid,
    required this.busy,
    required this.mode,
    required this.isLocked,
    required this.hasProfile,
    required this.userUUID,
  });

  factory TerminalConnectionModel.fromJson(Map<String, dynamic> json) {
    return TerminalConnectionModel(
      name: json['name'] as String?,
      tid: json['tid'] as String,
      uuid: json['uuid'] as String,
      busy: json['busy'] as bool? ?? false,
      mode: json['mode'] as String,
      isLocked: json['isLocked'] as bool? ?? false,
      hasProfile: json['hasProfile'] as bool? ?? false,
      userUUID: json['userUUID'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tid': tid,
      'uuid': uuid,
      'busy': busy,
      'mode': mode,
      'isLocked': isLocked,
      'hasProfile': hasProfile,
      'userUUID': userUUID,
    };
  }

  /// connectTerminal
  Future<TerminalModel> connect(FlutterTerminalSdk sdk) async {
    if (userUUID.isEmpty) {
      throw NearpayException('User UUID is missing');
    }
    if (tid.isEmpty) {
      throw NearpayException('Terminal TID is missing');
    }

    return sdk.connectTerminal(
      tid: tid,
      userUUID: userUUID,
      terminalUUID: uuid
    );
  }
}
