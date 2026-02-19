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

import '../commands.dart' show ServerVersionCheck, VectorSetCommands;

extension VSimCommand on VectorSetCommands {
  /// VSIM key (ELE | VALUES num) (element | vector) `[WITHSCORES]`
  /// [WITHATTRIBS] [COUNT num] [EPSILON delta] [EF ef]
  /// [FILTER expression] [FILTER-EF max-effort] `[TRUTH]` `[NOTHREAD]`
  ///
  /// Performs an approximate or exact similarity search within a vector set.
  ///
  /// [key]: The key of the vector set.
  ///
  /// [queryElement]: The ID of an existing element to use as the query (uses
  ///                 'ELE').
  /// [queryVector]: A raw vector to use as the query (uses 'VALUES').
  /// *Note*: Exactly one of [queryElement] or [queryVector] must be provided.
  ///
  /// [withScores]: Returns similarity scores.
  /// [withAttribs]: Returns JSON attributes associated with elements.
  /// [count]: Limits the number of results.
  /// [epsilon]: Returns elements within distance 'delta' (0.0 to 1.0).
  /// [ef]: Search exploration factor (higher = better recall, slower).
  /// [filter]: Filter expression string.
  /// [filterEf]: Max filtering effort.
  /// [truth]: Force exact linear scan (O(N)).
  /// [noThread]: Execute in main thread.
  /// [forceRun]: Force execution on Valkey.
  Future<List<dynamic>> vSim(
    String key, {
    String? queryElement,
    List<num>? queryVector,
    bool withScores = false,
    bool withAttribs = false,
    int? count,
    double? epsilon,
    int? ef,
    String? filter,
    int? filterEf,
    bool truth = false,
    bool noThread = false,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('VSIM', forceRun: forceRun);

    final cmd = <dynamic>['VSIM', key];

    // 1. Query Argument (ELE vs VALUES)
    if (queryElement != null) {
      cmd.addAll(['ELE', queryElement]);
    } else if (queryVector != null) {
      // Use VALUES syntax: VALUES <dim> <val1> <val2> ...
      cmd.add('VALUES');
      cmd.add(queryVector.length);
      // Ensure doubles are sent
      cmd.addAll(queryVector.map((e) => e.toDouble()));
    } else {
      throw ArgumentError(
          'Either queryElement or queryVector must be provided.');
    }

    // 2. Options
    if (withScores) cmd.add('WITHSCORES');

    if (await isRedis82OrLater()) {
      if (withAttribs) cmd.add('WITHATTRIBS');
    } else {
      throw UnsupportedError('Starting with Redis version 8.2.0: '
          'added the WITHATTRIBS option.');
    }

    if (count != null) cmd.addAll(['COUNT', count]);

    if (epsilon != null) cmd.addAll(['EPSILON', epsilon]);

    if (ef != null) cmd.addAll(['EF', ef]);

    if (filter != null) cmd.addAll(['FILTER', filter]);
    if (filterEf != null) cmd.addAll(['FILTER-EF', filterEf]);

    if (truth) cmd.add('TRUTH');
    if (noThread) cmd.add('NOTHREAD');

    // Returns a List of results (e.g., ["id1", "score1", "id2", "score2"...])
    final result = await execute(cmd);

    if (result is List) {
      return result;
    }
    return [];
  }
}
