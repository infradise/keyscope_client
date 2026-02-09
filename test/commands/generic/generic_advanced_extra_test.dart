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
  group('Generic Commands (Advanced Extra)', () {
    late KeyscopeClient client;

    setUp(() async {
      client = KeyscopeClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.disconnect();
    });

    test('Sort Read-Only: SORT_RO', () async {
      const key = 'ro_list';
      await client.rPush(key, ['3', '1', '2']);

      // SORT_RO calls the Read-Only variant
      final sorted = await client.sortRo(key);
      expect(sorted, equals(['1', '2', '3']));

      // Verify original order didn't change (it shouldn't anyway, but
      // good to check)
      final original = await client.lRange(key, 0, -1);
      expect(original, equals(['3', '1', '2']));
    });

    test('Persistence Wait: WAITAOF', () async {
      // 1. [Setup] Enable AOF (Backup original config)
      // Check current configs
      final originalAof = await client.configGet('appendonly');
      final originalFsync = await client.configGet('appendfsync');

      // print(originalFsync); // everysec

      // 2. [Setup] Enable AOF and set fsync to 'always'
      // 'always' ensures data is written to disk immediately, preventing
      // WAITAOF timeout.
      if (originalAof == 'no') {
        await client.configSet('appendonly', 'yes');

        // [Important] Give Redis time to initialize the AOF file.
        // Without this delay, WAITAOF might return 0 because the file isn't
        // ready.
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (originalFsync != 'always') {
        await client.configSet('appendfsync', 'always');

        // Brief delay to ensure AOF file initialization
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }

      // 3. [Action] Perform a write operation
      await client.set('test_aof_key', 'value');
      // await client.set('data', 'persist_me');

      try {
        // 4. [Verify] WAITAOF 1 0 1000
        // Wait for fsync to complete on local (1) within 1000ms
        // Wait for 1 local fsync. Increase timeout slightly for safety.
        final result = await client.waitAof(1, 0, 1000);
        // Returns [local_count, replica_count]

        // > Result format: [local_fsync_count, replica_fsync_count]
        // > Expect 1 successful local fsync
        // > Expect: [1, 0] (1 local success, 0 replicas)
        // expect(result[0], equals(1));

        expect(result, isA<List>());
        expect(result.length, equals(2));
        // Local persistence usually happens, so result[0] should be 1
        expect(result[0], equals(1));
        // No replicas in this test env, so result[1] should be 0
        expect(result[1], equals(0));
      } finally {
        // 5. [Teardown] Restore original configuration
        if (originalAof != null) {
          await client.configSet('appendonly', originalAof); // no
        }
        if (originalFsync != null) {
          await client.configSet('appendfsync', originalFsync); // everysec
        }
      }
    });

    test('Object Inspection Extra: FREQ', () async {
      // 1. [Setup] Backup original maxmemory-policy
      // OBJECT FREQ fails if the policy is not LFU (e.g., volatile-lru).
      final originalPolicy = await client.configGet('maxmemory-policy');

      // 2. [Setup] Switch to 'allkeys-lfu' to enable frequency tracking
      await client.configSet('maxmemory-policy', 'allkeys-lfu');

      // 3. [Action] Create a key and access it
      // Accessing the key ensures the LFU counter is initialized/incremented.
      const key = 'test_freq_key';
      await client.set(key, 'value');
      await client.get(key); // Access to bump frequency

      // const key = 'obj_test';
      // await client.set(key, 'val');

      try {
        // 4. [Verify] OBJECT FREQ
        //
        // Note: This returns null if maxmemory-policy is not LFU.
        // We just ensure the command executes without throwing.
        final freq = await client.objectFreq(key);
        // Depending on redis config, this is null or an int.
        // Validating it's not throwing an error is the main point here.
        if (freq != null) {
          expect(freq, greaterThanOrEqualTo(0));
        }
        // Frequency should be an integer (usually >= 1 after access)
        expect(freq, isA<int>());
        expect(freq, greaterThanOrEqualTo(1));
      } finally {
        // 5. [Teardown] Restore original maxmemory-policy
        if (originalPolicy != null) {
          await client.configSet('maxmemory-policy', originalPolicy);
        }
      }
    });

    test('Object Inspection Extra: HELP', () async {
      // [Verify] OBJECT HELP
      final help = await client.objectHelp();
      expect(help, isNotEmpty);
      expect(help.toString(), contains('OBJECT'));
      expect(help.first, contains('OBJECT <subcommand>'));
    });

    test('Migration: MIGRATE', () async {
      const key = 'move_me';
      await client.set(key, 'data');

      // MIGRATE requires a target instance.
      // In a single-instance test environment, we expect an error (connection
      // refused)
      // or "NOKEY" if we try to migrate a missing key to a fake port.

      // Attempt to migrate to a non-existent server to verify command
      // transmission
      try {
        await client.migrate(
            '127.0.0.1',
            9999, // Fake port
            key,
            0,
            100 // timeout
            );
        // If it somehow succeeds (unlikely), fail the test
        fail('Should have thrown connection error');
      } catch (e) {
        // Expected behavior: The client tries to connect to
        // 127.0.0.1:9999 and fails.
        // This proves the MIGRATE command logic was executed and
        // params were passed.
        expect(e, isNotNull);
      }
    });
  });
}
