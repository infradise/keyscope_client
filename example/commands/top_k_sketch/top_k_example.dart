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

  print('--- 🏆 Top-K Sketch Example ---');

  const key = 'trending:hashtags';

  // 1. TOPK.RESERVE
  print('1. Initializing Top-K Sketch (Tracking top 3 hashtags)...');
  await client.topkReserve(key, 3);

  // 2. TOPK.ADD
  print('2. Processing hashtag stream...');
  final hashtags = [
    '#dart',
    '#flutter',
    '#dart',
    '#redis',
    '#dart',
    '#flutter',
    '#valkey',
    '#dragonfly',
    '#memorystore',
    '#etc'
  ];

  // Adding items. Sometimes adding a new item kicks an old one out of
  // the top K.
  final droppedItems = await client.topkAdd(key, hashtags);

  // Safely check for dropped items
  final actuallyDropped = droppedItems.where((item) => item != null).toList();
  if (actuallyDropped.isNotEmpty) {
    print('   Items pushed out of the Top-3: $actuallyDropped');
  } else {
    print('   No items were pushed out yet.');
  }

  // 3. TOPK.INCRBY
  print('3. Boosting a hashtag score...');
  // Force #redis to the top by heavily incrementing it
  await client.topkIncrBy(key, {'#redis': 10});
  print('   Added 10 mentions to #redis.');

  // 4. TOPK.LIST (WITHCOUNT)
  print('4. Retrieving current Top-K list...');
  final topItems = await client.topkList(key, withCount: true);

  print('   --- Current Trending ---');
  // Iterate by 2 because WITHCOUNT returns [item1, count1, item2, count2...]
  for (var i = 0; i < topItems.length; i += 2) {
    final name = topItems[i];
    final count = topItems[i + 1];
    print('   Rank ${(i ~/ 2) + 1}: $name (Count: $count)');
  }

  // 5. TOPK.QUERY
  print('5. Querying specific hashtags...');
  final checkList = ['#redis', '#dart', '#etc'];
  final queryResults = await client.topkQuery(key, checkList);

  for (var i = 0; i < checkList.length; i++) {
    print('   Is ${checkList[i]} in the top 3? ${queryResults[i]}');
  }

  await client.disconnect();
  print('--- Done ---');
}
