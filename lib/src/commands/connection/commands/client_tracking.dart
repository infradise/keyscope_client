/*
 * Copyright 2025-2026 Infradise Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import '../commands.dart' show ConnectionCommands, ServerVersionCheck;

extension ClientTrackingCommand on ConnectionCommands {
  /// CLIENT TRACKING ON|OFF [REDIRECT client-id] [PREFIX prefix ...]
  ///   `[BCAST]` `[OPTIN]` `[OPTOUT]` `[NOLOOP]`
  /// Enables or disables the tracking feature of the Redis server.
  Future<dynamic> clientTracking(
    bool enable, {
    int? redirect,
    List<String>? prefixes,
    bool bcast = false,
    bool optIn = false,
    bool optOut = false,
    bool noLoop = false,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('CLIENT TRACKING', forceRun: forceRun);
    final cmd = <dynamic>['CLIENT', 'TRACKING', enable ? 'ON' : 'OFF'];

    if (redirect != null) {
      cmd.addAll(['REDIRECT', redirect]);
    }

    if (prefixes != null && prefixes.isNotEmpty) {
      for (final prefix in prefixes) {
        cmd.addAll(['PREFIX', prefix]);
      }
    }

    if (bcast) cmd.add('BCAST');
    if (optIn) cmd.add('OPTIN');
    if (optOut) cmd.add('OPTOUT');
    if (noLoop) cmd.add('NOLOOP');

    return execute(cmd);
  }
}
