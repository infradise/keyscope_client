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

import '../commands.dart' show HashCommands;

extension HMSetCommand on HashCommands {
  /// HMSET key field value [field value ...]
  ///
  /// Sets the specified fields to their respective values in the hash stored at
  /// [key].
  /// This command overwrites any specified fields already existing in the hash.
  /// If [key] does not exist, a new key holding a hash is created.
  ///
  /// Note: As of Redis 4.0.0, this command is regarded as deprecated.
  /// It can be replaced by HSET with multiple field-value pairs.
  ///
  /// Note: HMSET is normally available on Valkey.
  ///
  /// Internally, this uses the modern variadic `HSET` command which is
  /// more efficient and replaces the deprecated `HMSET` command, while keeping
  /// the familiar API.
  ///
  /// [data] is a map of field-value pairs to set.
  /// Returns the number of fields that were added (new fields).
  Future<int> hMSet(String key, Map<String, dynamic> data) async {
    if (data.isEmpty) return 0;

    // Use HSET instead of HMSET as HMSET is deprecated in newer Redis versions
    // HSET key field1 value1 field2 value2 ...
    // final cmd = <String>['HSET', key];
    final cmd = <String>['HMSET', key];
    data.forEach((field, value) {
      cmd.add(field);
      // cmd.add(value);
      cmd.add(value.toString());
    });

    return executeInt(cmd);
  }
}
