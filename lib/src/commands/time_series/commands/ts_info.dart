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

import '../commands.dart' show ServerVersionCheck, TimeSeriesCommands;

extension TsInfoCommand on TimeSeriesCommands {
  /// TS.INFO key `[DEBUG]`
  ///
  /// Get information and statistics on the time series.
  ///
  /// - [key]: The key name.
  /// - [debug]: If true, returns more detailed information.
  /// - [forceRun]: Force execution on Valkey.
  Future<dynamic> tsInfo(
    String key, {
    bool debug = false,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.INFO', forceRun: forceRun);
    final cmd = <dynamic>['TS.INFO', key];
    if (debug) cmd.add('DEBUG');
    return execute(cmd);
  }
}
