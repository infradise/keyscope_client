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

extension TsMRevRangeCommand on TimeSeriesCommands {
  /// TS.MREVRANGE fromTimestamp toTimestamp [LATEST] [FILTER_BY_TS ...]
  /// [FILTER_BY_VALUE ...] [WITHLABELS] [COUNT count] [ALIGN align]
  /// [AGGREGATION aggregator bucketDuration] [BUCKETTIMESTAMP ...]
  /// `[EMPTY]` FILTER filter...
  ///
  /// Query a range across multiple time series in reverse direction.
  ///
  /// - [fromTimestamp]: Start time.
  /// - [toTimestamp]: End time.
  /// - [filters]: Filter expressions.
  /// - [options]: Additional options.
  /// - [forceRun]: Force execution on Valkey.
  Future<dynamic> tsMRevRange(
    Object fromTimestamp,
    Object toTimestamp,
    List<String> filters, {
    List<dynamic> options = const [],
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TS.MREVRANGE', forceRun: forceRun);
    final cmd = <dynamic>[
      'TS.MREVRANGE',
      fromTimestamp,
      toTimestamp,
      ...options,
      'FILTER',
      ...filters
    ];
    return execute(cmd);
  }
}
