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

extension TsDelCommand on TimeSeriesCommands {
  /// TS.DEL key fromTimestamp toTimestamp
  ///
  /// Delete a range of samples.
  ///
  /// - [key]: The key name.
  /// - [fromTimestamp]: Start timestamp.
  /// - [toTimestamp]: End timestamp.
  /// - [forceRun]: Force execution on Valkey.
  Future<int> tsDel(
    String key,
    int fromTimestamp,
    int toTimestamp, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.DEL', forceRun: forceRun);

    // cmd contains Strings and ints, so it is List<dynamic>
    final cmd = <dynamic>['TS.DEL', key, fromTimestamp, toTimestamp];

    // NOTE: executeInt accepts List<String>, but we have List<dynamic>.
    // Use execute() directly and cast the result to int.
    final result = await execute(cmd);
    return result as int;
  }
}
