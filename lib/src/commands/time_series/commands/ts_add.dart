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

extension TsAddCommand on TimeSeriesCommands {
  /// TS.ADD key timestamp value [RETENTION retentionPeriod]
  /// [ENCODING uncompressed|compressed] [CHUNK_SIZE size]
  /// [ON_DUPLICATE policy] [LABELS field value..]
  ///
  /// Append a sample to a time series.
  ///
  /// - [key]: The key name of the time series.
  /// - [timestamp]: Timestamp in milliseconds, or '*' for automatic system
  ///                time.
  /// - [value]: The numeric value to append.
  /// - [options]: Optional arguments like RETENTION, LABELS, etc.
  /// - [forceRun]: Force execution on Valkey.
  Future<dynamic> tsAdd(
    String key,
    Object timestamp,
    num value, {
    List<dynamic> options = const [],
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.ADD', forceRun: forceRun);
    final cmd = <dynamic>['TS.ADD', key, timestamp, value, ...options];
    return execute(cmd);
  }
}
