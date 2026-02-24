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

extension ClientListCommand on ConnectionCommands {
  /// CLIENT LIST [TYPE type] [ID client-id [client-id ...]]
  /// Returns information and statistics about the client connections server.
  Future<String> clientList({
    String? type,
    List<int>? ids,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('CLIENT LIST', forceRun: forceRun);
    final cmd = <dynamic>['CLIENT', 'LIST'];
    if (type != null) {
      cmd.addAll(['TYPE', type]);
    }
    if (ids != null && ids.isNotEmpty) {
      cmd.add('ID');
      cmd.addAll(ids);
    }
    final result = await execute(cmd);
    return result.toString();
  }
}
