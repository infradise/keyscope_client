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

import 'package:test/test.dart';
import 'package:valkey_client/valkey_client.dart';

void main() {
  group('String Commands - Extra (MSETEX, DIGEST, DELEX)', () {
    late ValkeyClient client;

    setUp(() async {
      client = ValkeyClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close(); // disconnect
    });

    test('MSETEX', () async {
      const k1 = 'test:msetex:1';
      const k2 = 'test:msetex:2';

      // 1. MSETEX with EX option
      // Library sends: MSETEX 2 k1 v1 k2 v2 EX 10
      final result = await client.mSetEx({
        k1: 'v1',
        k2: 'v2',
      }, ex: 10);

      expect(result, equals(1)); // Returns 1 on success

      // 2-1. Verify values
      final values = await client.mGet([k1, k2]);
      expect(values, equals(['v1', 'v2']));

      // 2-2. Verify values and TTL
      expect(await client.get(k1), equals('v1'));
      final ttl = await client.ttl(k1);
      expect(ttl, inInclusiveRange(1, 10));
    });

    test('DELEX with IFEQ / IFNE', () async {
      const key = 'test:delex:cond';

      // 1. IFEQ - Success
      await client.set(key, 'target');
      final res1 = await client.delEx(key, ifEq: 'target');
      expect(res1, equals(1));
      expect(await client.exists(key), equals(0));

      // 2. IFEQ - Fail (Value mismatch)
      await client.set(key, 'target');
      final res2 = await client.delEx(key, ifEq: 'wrong');
      expect(res2, equals(0));
      expect(await client.exists(key), equals(1));

      // 3. IFNE - Success
      final res3 = await client.delEx(key, ifNe: 'wrong');
      expect(res3, equals(1)); // 'target' != 'wrong', so delete
    });

    test('DIGEST and DELEX with IFDEQ', () async {
      const key = 'test:delex:digest';
      const value = 'some_long_value_to_hash';

      await client.set(key, value);

      // 1. Get Digest
      final digest = await client.digest(key);
      expect(digest, isNotNull);

      // 2. IFDEQ - Success (Digest Match)
      final res = await client.delEx(key, ifDeq: digest!);
      expect(res, equals(1));
      expect(await client.exists(key), equals(0));
    });
  });
}
