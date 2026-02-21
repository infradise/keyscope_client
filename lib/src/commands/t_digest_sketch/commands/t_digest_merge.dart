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

extension TDigestMergeCommand on TDigestSketchCommands {
  /// TDIGEST.MERGE destination_key numKeys source_key [source_key ...]
  /// [COMPRESSION compression] `[OVERRIDE]`
  /// Merges multiple t-digest sketches into a single sketch.
  Future<dynamic> tDigestMerge(
    String destinationKey,
    List<String> sourceKeys, {
    int? compression,
    bool override = false,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TDIGEST.MERGE', forceRun: forceRun);
    final cmd = <dynamic>[
      'TDIGEST.MERGE',
      destinationKey,
      sourceKeys.length,
      ...sourceKeys
    ];

    if (compression != null) {
      cmd.addAll(['COMPRESSION', compression]);
    }

    if (override) {
      cmd.add('OVERRIDE');
    }

    return execute(cmd);
  }
}
