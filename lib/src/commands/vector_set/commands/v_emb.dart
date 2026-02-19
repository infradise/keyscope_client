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

extension VEmbCommand on VectorSetCommands {
  /// VEMB key id
  ///
  /// Returns the vector embedding for a given ID.
  ///
  /// [key]: The key of the vector set.
  /// [id]: The identifier of the vector.
  /// [forceRun]: Force execution on Valkey.
  Future<List<double>> vEmb(
    String key,
    String id, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('VEMB', forceRun: forceRun);

    final result = await execute(['VEMB', key, id]);

    // Handle binary response
    if (result is List<int>) {
      return unpackVector(result);
    } else if (result is List) {
      // Fallback if server returns list of strings/numbers
      return result.map((e) => double.parse(e.toString())).toList();
    }
    return [];
  }
}
