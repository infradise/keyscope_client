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

extension TDigestByRevRankCommand on TDigestSketchCommands {
  /// TDIGEST.BYREVRANK key rev_rank [rev_rank ...]
  /// Returns the value(s) associated with the specified reverse rank(s).
  Future<List<double>> tDigestByRevRank(
    String key,
    List<int> revRanks, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TDIGEST.BYREVRANK', forceRun: forceRun);
    final result = await execute(['TDIGEST.BYREVRANK', key, ...revRanks]);
    if (result is List) {
      return result.map((e) => double.parse(e.toString())).toList();
    }
    return [];
  }
}
