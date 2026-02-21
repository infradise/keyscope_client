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

import 'package:keyscope_client/keyscope_client.dart';

Future<void> main() async {
  final client = KeyscopeClient(host: 'localhost', port: 6379);
  await client.connect();

  // Redis Only Feature
  if (!await client.isRedis) {
    print('⚠️  Skipping: This example requires a Redis server.');
    print('   Current server appears to be Valkey or other compatible server.');
    await client.close(); // disconnect
    return;
  }

  await client.flushAll();

  print('--- 📊 Count-Min Sketch Example ---');

  const sketchKey = 'views:videos';

  // 1. CMS.INITBYPROB
  print('1. Initializing Count-Min Sketch...');
  // Initialize with 0.1% error rate and 1% probability of exceeding
  // the error rate
  await client.cmsInitByProb(sketchKey, 0.001, 0.01);

  // 2. CMS.INCRBY
  print('2. Tracking video views...');
  final increments = {'video_A': 150, 'video_B': 80, 'video_C': 10};

  await client.cmsIncrBy(sketchKey, increments);

  // Simulate another batch of views
  await client.cmsIncrBy(sketchKey, {'video_A': 50, 'video_D': 5});
  print('   Updated view counts successfully.');

  // 3. CMS.QUERY
  print('3. Querying approximate view counts...');
  final queryList = ['video_A', 'video_B', 'video_C', 'video_D', 'video_E'];
  final counts = await client.cmsQuery(sketchKey, queryList);

  for (var i = 0; i < queryList.length; i++) {
    print('   ${queryList[i]} views: ${counts[i]}');
  }
  // Expected Output:
  // video_A views: ~200
  // video_B views: ~80
  // video_C views: ~10
  // video_D views: ~5
  // video_E views: ~0

  // 4. CMS.INFO
  print('4. Inspecting sketch details...');
  final info = await client.cmsInfo(sketchKey);
  print('   Sketch Info: $info');

  await client.disconnect();
}
