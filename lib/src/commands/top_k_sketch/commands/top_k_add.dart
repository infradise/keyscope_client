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

extension TopKAddCommand on TopKSketchCommands {
  /// TOPK.ADD key item [item ...]
  /// Adds one or more items to the TopK data structure.
  /// Returns a list of elements dropped from the TopK list.
  /// Null indicates no drop.
  Future<List<String?>> topkAdd(
    String key,
    List<String> items, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TOPK.ADD', forceRun: forceRun);

    final result = await execute(['TOPK.ADD', key, ...items]);
    if (result is List) {
      return result.map((e) => e?.toString()).toList();
    }
    return [];
  }
}
