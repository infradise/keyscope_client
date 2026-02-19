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

extension VRangeCommand on VectorSetCommands {
  /// VRANGE key start end [count]
  ///
  /// Iterates over elements in the vector set in lexicographical order.
  ///
  /// [key]: The name of the vector set key.
  /// [start]: Start of range (e.g., '[a', '(a', '-').
  /// [end]: End of range (e.g., '[z', '(z', '+').
  /// [count]: Max number of elements to return (negative for all).
  /// [forceRun]: Force execution on Valkey.
  Future<dynamic> vRange(
    String key,
    String start,
    String end, {
    int? count,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('VRANGE', forceRun: forceRun);

    // Command: VRANGE key start end [count]
    final cmd = <dynamic>['VRANGE', key, start, end];

    if (count != null) {
      cmd.add(count);
    }

    final result = await execute(cmd);

    if (result is List) {
      return result.map((e) => e.toString()).toList();
    }
    return [];
  }
}
