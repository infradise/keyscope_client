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

extension CmsQueryCommand on CountMinSketchCommands {
  /// CMS.QUERY key item [item ...]
  /// Returns count for one or more items in a sketch.
  Future<List<int>> cmsQuery(
    String key,
    List<String> items, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('CMS.QUERY', forceRun: forceRun);

    final result = await execute(['CMS.QUERY', key, ...items]);
    if (result is List) {
      return result.map((e) => int.parse(e.toString())).toList();
    }
    return [];
  }
}
