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
  group('T-Digest - Merge Operations', () {
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

    testRedis('MERGE multiple sketches', () async {
      const src1 = 'td:src1';
      const src2 = 'td:src2';
      const dest = 'td:dest';

      // Initialize source keys before adding data
      await client.tDigestCreate(src1);
      await client.tDigestCreate(src2);

      await client.tDigestAdd(src1, [1.0, 2.0, 3.0]);
      await client.tDigestAdd(src2, [4.0, 5.0, 6.0]);

      // Note: TDIGEST.MERGE automatically creates the destination key if
      //       it does not exist.
      // Merge src1 and src2 into dest
      await client.tDigestMerge(dest, [src1, src2]);

      // Verify dest
      final maxVal = await client.tDigestMax(dest);
      final minVal = await client.tDigestMin(dest);

      expect(minVal, closeTo(1.0, 0.01));
      expect(maxVal, closeTo(6.0, 0.01));
    });
  });
}
