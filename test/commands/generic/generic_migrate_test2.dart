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
  group('MIGRATE Command Tests', () {
    late KeyscopeClient sourceClient;
    late KeyscopeClient targetClient;

    // Source Redis (Sender)
    const srcHost = 'localhost';
    const srcPort = 6379;

    // Target Redis (Receiver) - Must be running
    const targetHost = 'localhost';
    const targetPort = 6380;

    setUp(() async {
      // 1. Connect and initialize Source
      sourceClient = KeyscopeClient(host: srcHost, port: srcPort);
      await sourceClient.connect();
      await sourceClient.flushAll();

      // 2. Connect and initialize Target (For verification)
      targetClient = KeyscopeClient(host: targetHost, port: targetPort);
      await targetClient.connect();
      await targetClient.flushAll();
    });

    tearDown(() async {
      await sourceClient.disconnect();
      await targetClient.disconnect();
    });

    test('MIGRATE: Move key from Source to Target', () async {
      const key = 'migrate_key';
      const value = 'Hello Migration';

      // 1. Create data in Source
      await sourceClient.set(key, value);
      expect(await sourceClient.exists([key]), equals(1));

      // 2. Execute MIGRATE
      // Move key to 127.0.0.1:6380
      final result = await sourceClient.migrate(
          '127.0.0.1', // Target Host (Address recognized by Redis)
          targetPort, // Target Port
          key, // Key to migrate
          0, // Destination DB
          5000 // Timeout (ms)
          );

      expect(result, equals('OK'));

      // 3. Verify results
      // Should disappear from Source (COPY option not used)
      expect(await sourceClient.exists([key]), equals(0));

      // Should exist in Target
      expect(await targetClient.get(key), equals(value));
    });

    test('MIGRATE with COPY & REPLACE', () async {
      const key = 'copy_key';
      const value = 'Persistent Data';

      // 1. Create data in Source
      await sourceClient.set(key, value);

      // 2. Create data in Target beforehand (To test REPLACE)
      await targetClient.set(key, 'Old Data');

      // 3. Execute MIGRATE (Using COPY, REPLACE options)
      final result =
          await sourceClient.migrate('127.0.0.1', targetPort, key, 0, 5000,
              copy: true, // Copy (Remains in Source)
              replace: true // Replace (Overwrite Target value)
              );

      expect(result, equals('OK'));

      // 4. Verify results
      // Should still exist in Source (COPY)
      expect(await sourceClient.get(key), equals(value));

      // Target data should be updated (REPLACE)
      expect(await targetClient.get(key), equals(value));
    });

    test('MIGRATE with KEYS (Multiple Keys)', () async {
      const k1 = 'k1';
      const k2 = 'k2';

      await sourceClient.set(k1, 'v1');
      await sourceClient.set(k2, 'v2');

      // MIGRATE multiple keys
      // Leave key argument empty ('') and use keys parameter
      final result = await sourceClient.migrate(
          '127.0.0.1',
          targetPort,
          '', // ignored
          0,
          5000,
          keys: [k1, k2]);

      expect(result, equals('OK'));

      // Verify Source (Gone)
      expect(await sourceClient.exists([k1, k2]), equals(0));

      // Verify Target (Arrived)
      expect(await targetClient.exists([k1, k2]), equals(2));
      expect(await targetClient.get(k1), equals('v1'));
    });
  });
}
