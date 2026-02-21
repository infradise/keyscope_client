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
  group('T-Digest - Lifecycle Operations', () {
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

    testRedis('CREATE, ADD, INFO, and RESET', () async {
      const key = 'td:lifecycle';

      // 1. TDIGEST.CREATE
      await client.tDigestCreate(key, compression: 100);

      // 2. TDIGEST.ADD
      await client.tDigestAdd(key, [1.0, 2.0, 3.0]);

      // 3. TDIGEST.INFO
      final info = await client.tDigestInfo(key);
      expect(info, isNotNull);
      expect(info.toString().toLowerCase(), contains('compression'));

      // 4. TDIGEST.RESET
      await client.tDigestReset(key);

      // Verify reset by adding a new unique item and checking max
      await client.tDigestAdd(key, [100.0]);
      final maxVal = await client.tDigestMax(key);
      expect(maxVal, equals(100.0));
    });
  });
}
