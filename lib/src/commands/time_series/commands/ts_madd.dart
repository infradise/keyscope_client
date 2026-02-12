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

extension TsMAddCommand on TimeSeriesCommands {
  /// TS.MADD key timestamp value [key timestamp value ...]
  ///
  /// Append samples to multiple time series.
  ///
  /// - [samples]: A list of samples, where each sample is a
  ///              List [key, timestamp, value].
  /// - [forceRun]: Force execution on Valkey.
  Future<List<dynamic>> tsMAdd(
    List<List<dynamic>> samples, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.MADD', forceRun: forceRun);
    final cmd = <dynamic>['TS.MADD'];
    for (final sample in samples) {
      cmd.addAll(sample);
    }
    final result = await execute(cmd);
    return result as List<dynamic>;
  }
}
