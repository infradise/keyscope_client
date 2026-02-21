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

import '../commands.dart' show CountMinSketchCommands, ServerVersionCheck;

extension CmsMergeCommand on CountMinSketchCommands {
  /// CMS.MERGE dest numKeys src [src ...] [WEIGHTS weight [weight ...]]
  /// Merges several sketches into one sketch.
  Future<dynamic> cmsMerge(
    String dest,
    List<String> sources, {
    List<int>? weights,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('CMS.MERGE', forceRun: forceRun);

    final cmd = <dynamic>['CMS.MERGE', dest, sources.length];
    cmd.addAll(sources);

    if (weights != null) {
      if (weights.length != sources.length) {
        throw ArgumentError('Weights length must match sources length.');
      }
      cmd.add('WEIGHTS');
      cmd.addAll(weights);
    }

    return execute(cmd);
  }
}
