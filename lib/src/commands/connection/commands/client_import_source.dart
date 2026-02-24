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

extension ClientImportSourceCommand on ConnectionCommands {
  /// CLIENT IMPORT-SOURCE
  /// (Available in some Valkey/Redis environments for replication/import flows).
  /// We expose it generically as it often takes varying arguments depending on
  /// the context.
  Future<dynamic> clientImportSource(
    List<String> args, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('CLIENT IMPORT-SOURCE', forceRun: forceRun);
    return execute(['CLIENT', 'IMPORT-SOURCE', ...args]);
  }
}
