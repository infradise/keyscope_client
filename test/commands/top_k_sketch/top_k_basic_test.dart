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
import 'package:test/test.dart';

void main() {
  group('Top-K Sketch - Basic Lifecycle', () {
    late KeyscopeClient client;
    var isRedis = false;
    const port = 6379;

    setUpAll(() async {
      final tempClient = KeyscopeClient(host: 'localhost', port: port);
      try {
        await tempClient.connect();
        isRedis = await tempClient.isRedisServer();
      } catch (e) {
        print('Warning: Failed to check server type in setUpAll: $e');
      } finally {
        await tempClient.close();
      }
    });

    setUp(() async {
      client = KeyscopeClient(host: 'localhost', port: port);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      try {
        if (client.isConnected) {
          await client.disconnect();
        }
      } catch (_) {}
    });

    void testRedis(String description, Future<void> Function() body) {
      test(description, () async {
        if (!isRedis) {
          markTestSkipped('Skipping: This feature is supported on Redis only.');
          return;
        }
        await body();
      });
    }

    testRedis('Reserve, Add, Count, and Query', () async {
      const key = 'topk:test';

      // 1. TOPK.RESERVE (Track top 3 items)
      await client.topkReserve(key, 3);

      // 2. TOPK.ADD
      final addRes = await client.topkAdd(
        key,
        ['apple', 'apple', 'banana', 'cherry', 'date'],
      );

      // The length of the result matches the number of elements added.
      // If an element causes another to be dropped from the Top K,
      // the dropped element's name is returned. Otherwise, null.
      expect(addRes, isA<List<String?>>());
      expect(addRes.length, equals(5));

      // 3. TOPK.COUNT
      final countRes = await client.topkCount(
        key,
        ['apple', 'banana', 'date', 'grape'],
      );
      expect(countRes[0], equals(2)); // apple was added twice
      expect(countRes[3], equals(0)); // grape was never added

      // 4. TOPK.QUERY (Are they currently in the Top 3?)
      final queryRes = await client.topkQuery(
        key,
        ['apple', 'grape'],
      );
      expect(queryRes[0], isTrue); // apple is likely in top 3
      expect(queryRes[1], isFalse); // grape is definitely not

      // 5. TOPK.LIST
      final topkList = await client.topkList(key);
      expect(topkList.length, lessThanOrEqualTo(3)); // Max 3 items
      expect(topkList, contains('apple'));

      // 6. TOPK.INFO
      final info = await client.topkInfo(key);
      expect(info, isNotNull);
      expect(info.toString().toLowerCase(), contains('k'));
    });

    testRedis('Increment By and List with Count', () async {
      const key = 'topk:scores';

      // Track Top 2
      await client.topkReserve(key, 2);

      // 1. TOPK.INCRBY
      await client.topkIncrBy(
        key,
        {'player1': 100, 'player2': 50, 'player3': 150},
      );

      // 2. TOPK.LIST WITHCOUNT
      // Note: Cast safely since result can contain both
      //       String (names) and int (counts)
      final listRes = await client.topkList(key, withCount: true);

      expect(
          listRes.length, lessThanOrEqualTo(4)); // 2 items * 2 (item + count)
      final stringResult = listRes.map((e) => e.toString()).toList();

      expect(
          stringResult, contains('player3')); // Highest score, should be there
      expect(stringResult, contains('150')); // The score itself
    });
  });
}
