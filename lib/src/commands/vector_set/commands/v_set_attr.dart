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

import 'dart:convert' show jsonEncode;

import '../commands.dart' show ServerVersionCheck, VectorSetCommands;

extension VSetAttrCommand on VectorSetCommands {
  /// VSETATTR key id attributes
  ///
  /// Updates the attributes associated with the vector.
  ///
  /// [key]: The key of the vector set.
  /// [id]: The vector ID.
  /// [attributes]: A map of attributes to set (will be converted to JSON
  ///               string).
  /// - `[attribute]`: The attribute name.
  /// - `[value]`: The value to set.
  /// [forceRun]: Force execution on Valkey.
  Future<dynamic> vSetAttr(
    String key,
    String id,
    Map<String, dynamic> attributes, // Accept Map instead of single key-value
    {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('VSETATTR', forceRun: forceRun);

    // Convert Map to JSON string
    // (e.g., {"category":"electronics", "price":100})
    final jsonAttr = jsonEncode(attributes);

    // Command: VSETATTR key id json_string
    return execute(['VSETATTR', key, id, jsonAttr]);
  }
}
