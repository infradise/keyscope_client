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

import '../commands.dart' show ServerVersionCheck, TopKSketchCommands;

extension TopKListCommand on TopKSketchCommands {
  /// TOPK.LIST key `[WITHCOUNT]`
  /// Returns the full list of items in the TopK list.
  /// If [withCount] is true, the result will interleave items and their counts.
  Future<List<dynamic>> topkList(
    String key, {
    bool withCount = false,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TOPK.LIST', forceRun: forceRun);

    final cmd = <dynamic>['TOPK.LIST', key];
    if (withCount) {
      cmd.add('WITHCOUNT');
    }

    final result = await execute(cmd);
    if (result is List) {
      return result;
    }
    return [];
  }
}
