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

extension CmsInitByProbCommand on CountMinSketchCommands {
  /// CMS.INITBYPROB key error probability
  /// Initializes a Count-Min Sketch to accommodate requested error and
  /// probability.
  Future<dynamic> cmsInitByProb(
    String key,
    double error,
    double probability, {
    bool forceRun = false,
  }) async {
    await checkValkeySupport('CMS.INITBYPROB', forceRun: forceRun);
    return execute(['CMS.INITBYPROB', key, error, probability]);
  }
}
