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

import 'dart:convert' show jsonDecode;

import '../commands.dart' show ServerVersionCheck, VectorSetCommands;

extension VGetAttrCommand on VectorSetCommands {
  /// VGETATTR key element
  ///
  /// Retrieves the attributes (JSON object) associated with an element.
  /// Returns a [Map<String, dynamic>] if successful.
  ///
  /// [key]: The key of the vector set.
  /// [element]: The element ID.
  /// [forceRun]: Force execution on Valkey.
  Future<dynamic> vGetAttr(
    String key,
    String element, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('VGETATTR', forceRun: forceRun);

    // Returns: JSON string (e.g., "{\"color\":\"red\"}")
    final result = await execute(['VGETATTR', key, element]);

    if (result == null) return null;

    try {
      if (result is String) {
        return jsonDecode(result) as Map<String, dynamic>;
      } else if (result is List) {
        // In case some client/server versions return list of bytes/strings
        // Join or parse accordingly. Usually it's a Bulk String.
        return jsonDecode(result.join()) as Map<String, dynamic>;
      }
      return jsonDecode(result.toString()) as Map<String, dynamic>;
    } catch (e) {
      // If parsing fails or result is empty
      return {};
    }
  }
}
