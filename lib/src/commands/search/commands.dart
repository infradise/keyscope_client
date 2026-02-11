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

import '../commands.dart' show Commands;
import '../extensions/server_version_check.dart';

export 'extensions.dart';

mixin SearchCommands on Commands {
  /// Helper to check if the command is supported in Valkey.
  ///
  /// Throws [Exception] if [isValkey] is true and [forceRun] is false.
  ///
  /// [commandName]: The name of the command to check (e.g., 'FT.AGGREGATE').
  /// [forceRun]: If true, bypasses the check and allows execution.
  /// Force execution for Valkey/Redis compatibility check.
  Future<void> checkValkeySupport(String commandName, bool forceRun) async {
    if (await isValkey && await isRedisOnlyCommand(commandName) || !forceRun) {
      throw Exception(
          'Command $commandName is not currently supported in your server. '
          'Pass `forceRun: true` to execute it anyway.');
    }
  }
}
