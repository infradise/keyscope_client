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

extension TopKReserveCommand on TopKSketchCommands {
  /// TOPK.RESERVE key topk [width depth decay]
  /// Initializes a TopK with specified parameters.
  Future<dynamic> topkReserve(
    String key,
    int topk, {
    int? width,
    int? depth,
    double? decay,
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TOPK.RESERVE', forceRun: forceRun);

    final cmd = <dynamic>['TOPK.RESERVE', key, topk];

    // If one optional parameter is provided, usually all must be provided
    // according to Redis API, but we pass them if they exist.
    if (width != null) cmd.add(width);
    if (depth != null) cmd.add(depth);
    if (decay != null) cmd.add(decay);

    return execute(cmd);
  }
}
