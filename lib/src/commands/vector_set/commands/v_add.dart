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

extension VAddCommand on VectorSetCommands {
  /// VADD key [REDUCE dim] (FP32 | VALUES num) vector element `[CAS]`
  /// [NOQUANT | Q8 | BIN] [EF ef] [SETATTR attributes] [M numlinks]
  ///
  /// Add a new element into the vector set.
  ///
  /// [key]: The name of the key.
  /// [vector]: The vector data (List of numbers).
  /// [element]: The ID of the element (Required).
  ///
  /// [reduce]: Reduces dimensionality using random projection.
  /// [cas]: Performs operation in check-and-set style (background neighbor
  ///        search).
  /// [noQuant]: Force no quantization (Float32). Mutually exclusive with [q8],
  ///            [bin].
  /// [q8]: Force signed 8-bit quantization.
  /// [bin]: Force binary quantization.
  /// [ef]: Build exploration factor (default 200).
  /// [setAttr]: JSON object string for attributes.
  /// [m]: Max number of connections per node (default 16).
  /// [forceRun]: Force execution on Valkey.
  Future<dynamic> vAdd(
    String key,
    List<num> vector,
    String element, {
    // ID is required and positional in Redis 8
    int? reduce,
    bool cas = false,
    bool noQuant = false,
    bool q8 = false,
    bool bin = false,
    int? ef,
    String? setAttr,
    int? m,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('VADD', forceRun: forceRun);

    final cmd = <dynamic>['VADD', key];

    // 1. REDUCE option (Must be before vector)
    if (reduce != null) {
      cmd.addAll(['REDUCE', reduce]);
    }

    // 2. Vector Data (Using VALUES syntax for explicit specification)
    // Syntax: VALUES <dim> <val1> <val2> ...
    cmd.add('VALUES');
    cmd.add(vector.length);
    cmd.addAll(vector);

    // 3. Element ID (Positional, immediately after vector)
    cmd.add(element);

    // 4. Post-vector Options
    if (cas) cmd.add('CAS');

    // Quantization options (Mutually exclusive)
    if (noQuant) {
      cmd.add('NOQUANT');
    } else if (q8) {
      cmd.add('Q8');
    } else if (bin) {
      cmd.add('BIN');
    }

    if (ef != null) cmd.addAll(['EF', ef]);

    if (setAttr != null) cmd.addAll(['SETATTR', setAttr]);

    if (m != null) cmd.addAll(['M', m]);

    // NOTE: Separate RESP2 and RESP3
    // One of the following:
    // - RESP2 or RESP3
    //   - [RESP2] Integer reply: 1 if key was added; 0 if key was not added.
    //   - [RESP3] Boolean reply: true if key was added; false if key was not
    //             added.
    // - Simple error reply: if the command was malformed.

    return execute(cmd);
  }
}
