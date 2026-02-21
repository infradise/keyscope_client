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

import '../commands.dart' show ServerVersionCheck, TDigestSketchCommands;

extension TDigestAddCommand on TDigestSketchCommands {
  /// TDIGEST.ADD key value [value ...]
  /// Adds one or more observations to a t-digest sketch.
  Future<dynamic> tDigestAdd(
    String key,
    List<double> values, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('TDIGEST.ADD', forceRun: forceRun);
    return execute(['TDIGEST.ADD', key, ...values]);
  }
}
