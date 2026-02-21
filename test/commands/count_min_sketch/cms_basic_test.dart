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
  group('Count-Min Sketch - Basic Lifecycle', () {
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

    testRedis('Init, IncrBy, Query, and Info', () async {
      const key = 'cms:test';

      // 1. CMS.INITBYPROB
      await client.cmsInitByProb(key, 0.001, 0.01);

      // 2. CMS.INCRBY
      final incrRes = await client.cmsIncrBy(
        key,
        {'apple': 5, 'banana': 3},
      );
      // Expected returns: the updated count for each item
      expect(incrRes, equals([5, 3]));

      // 3. CMS.QUERY
      final queryRes = await client.cmsQuery(
        key,
        ['apple', 'banana', 'cherry'],
      );
      // 'cherry' was never incremented, so count is 0
      expect(queryRes, equals([5, 3, 0]));

      // 4. CMS.INFO
      final info = await client.cmsInfo(key);
      expect(info, isNotNull);
      expect(info.toString().toLowerCase(), contains('width'));
    });

    testRedis('Merge Sketches', () async {
      const src1 = 'cms:src1';
      const src2 = 'cms:src2';
      const dest = 'cms:dest';

      // Initialize destination and source sketches with identical dimensions
      await client.cmsInitByDim(src1, 1000, 5);
      await client.cmsInitByDim(src2, 1000, 5);
      await client.cmsInitByDim(dest, 1000, 5);

      // Add data to sources
      await client.cmsIncrBy(src1, {'user1': 10});
      await client.cmsIncrBy(src2, {'user1': 5, 'user2': 20});

      // CMS.MERGE
      await client.cmsMerge(dest, [src1, src2]);

      // Query destination
      final queryRes = await client.cmsQuery(dest, ['user1', 'user2']);
      // user1: 10 + 5 = 15, user2: 0 + 20 = 20
      expect(queryRes, equals([15, 20]));

      // CMS.MERGE with WEIGHTS (src1 * 2, src2 * 1)
      const destWeighted = 'cms:dest_weight';
      await client.cmsInitByDim(destWeighted, 1000, 5);
      await client.cmsMerge(
        destWeighted,
        [src1, src2],
        weights: [2, 1],
      );

      final queryWeighted = await client.cmsQuery(destWeighted, ['user1']);
      // user1: (10 * 2) + (5 * 1) = 25
      expect(queryWeighted, equals([25]));
    });
  });
}
