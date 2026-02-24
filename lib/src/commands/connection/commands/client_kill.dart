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

extension ClientKillCommand on ConnectionCommands {
  /// CLIENT KILL [ip:port] [ID client-id] [TYPE normal|master|replica|pubsub]
  ///   [USER username] [ADDR ip:port] [LADDR ip:port] [SKIPME yes/no]
  /// Closes a given client connection. Returns the number of clients killed.
  Future<int> clientKill({
    String? address, // For the old format: CLIENT KILL ip:port
    int? id,
    String? type,
    String? user,
    String? addr,
    String? laddr,
    String? skipMe,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('CLIENT KILL', forceRun: forceRun);
    final cmd = <dynamic>['CLIENT', 'KILL'];

    if (address != null) {
      cmd.add(address);
    } else {
      // Using 'ID' (int) mixed with Strings necessitates dynamic list initially
      if (id != null) cmd.addAll(['ID', id]);
      if (type != null) cmd.addAll(['TYPE', type]);
      if (user != null) cmd.addAll(['USER', user]);
      if (addr != null) cmd.addAll(['ADDR', addr]);
      if (laddr != null) cmd.addAll(['LADDR', laddr]);
      if (skipMe != null) cmd.addAll(['SKIPME', skipMe]);
    }

    // Convert List<dynamic> to List<String> before passing to executeInt
    return executeInt(cmd.map((e) => e.toString()).toList());
  }
}
