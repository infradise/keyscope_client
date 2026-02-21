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

import '../commands.dart' show ServerVersionCheck, TDigestSketchCommands;

extension TDigestRankCommand on TDigestSketchCommands {
  /// TDIGEST.RANK key value [value ...]
  /// Returns the number of observations less than or equal to
  /// the specified value(s).
  Future<List<int>> tDigestRank(
    String key,
    List<double> values, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TDIGEST.RANK', forceRun: forceRun);
    final result = await execute(['TDIGEST.RANK', key, ...values]);
    if (result is List) {
      // Rankings could be represented as floats or ints depending on
      // Redis version. Safely parse.
      return result.map((e) => double.parse(e.toString()).toInt()).toList();
    }
    return [];
  }
}
