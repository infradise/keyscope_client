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

extension TsQueryIndexCommand on TimeSeriesCommands {
  /// TS.QUERYINDEX filter...
  ///
  /// Get all the keys matching the filter list.
  ///
  /// - [filters]: List of filter expressions.
  /// - [forceRun]: Force execution on Valkey.
  Future<List<String>> tsQueryIndex(
    List<String> filters, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.QUERYINDEX', forceRun: forceRun);
    final cmd = <dynamic>['TS.QUERYINDEX', ...filters];
    final result = await execute(cmd);
    return (result as List).map((e) => e.toString()).toList();
  }
}
