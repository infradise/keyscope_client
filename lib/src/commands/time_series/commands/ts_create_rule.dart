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

extension TsCreateRuleCommand on TimeSeriesCommands {
  /// TS.CREATERULE sourceKey destKey AGGREGATION aggregator bucketDuration
  /// [alignTimestamp]
  ///
  /// Create a compaction rule.
  ///
  /// - [sourceKey]: The source time series key.
  /// - [destKey]: The destination (compacted) time series key.
  /// - [aggregator]: The aggregation type (e.g., avg, sum, min, max).
  /// - [bucketDuration]: Duration of each bucket in milliseconds.
  /// - [alignTimestamp]: Optional alignment timestamp.
  /// - [forceRun]: Force execution on Valkey.
  Future<dynamic> tsCreateRule(
    String sourceKey,
    String destKey,
    String aggregator,
    int bucketDuration, {
    int? alignTimestamp,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.CREATERULE', forceRun: forceRun);
    final cmd = <dynamic>[
      'TS.CREATERULE',
      sourceKey,
      destKey,
      'AGGREGATION',
      aggregator,
      bucketDuration
    ];
    if (alignTimestamp != null) {
      cmd.add(alignTimestamp);
    }
    return execute(cmd);
  }
}
