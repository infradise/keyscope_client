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
  group('Vector Set - Basic Lifecycle', () {
    late KeyscopeClient client;

    setUp(() async {
      client = KeyscopeClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.disconnect();
    });

    test('Add, Count, and Dimension', () async {
      const key = 'vec:users';

      // 1. VADD (Add vectors)
      // Vector dimension: 3
      // ID is now a required positional argument
      await client.vAdd(key, [0.1, 0.2, 0.3], 'user:1');
      await client.vAdd(key, [0.4, 0.5, 0.6], 'user:2');

      // 2. VCARD (Count)
      final count = await client.vCard(key);
      expect(count, equals(2));

      // 3. VDIM (Dimension check)
      final dim = await client.vDim(key);
      expect(dim, equals(3));
    });

    test('Membership, Info, and Removal', () async {
      const key = 'vec:items';
      // ID passed as positional argument
      await client.vAdd(key, [1.0, 0.0], 'item:A');

      // 1. VISMEMBER
      final exists = await client.vIsMember(key, 'item:A');
      expect(exists, isTrue);

      final notExists = await client.vIsMember(key, 'item:Z');
      expect(notExists, isFalse);

      // 2. VINFO
      final info = await client.vInfo(key);
      expect(info, isNotNull);
      // Depending on response structure, verify content
      expect(info.toString(), contains('dim'));

      // 3. VREM
      final deleted = await client.vRem(key, 'item:A');
      expect(deleted, equals(1));

      final countAfter = await client.vCard(key);
      expect(countAfter, equals(0));
    });
  });
}
