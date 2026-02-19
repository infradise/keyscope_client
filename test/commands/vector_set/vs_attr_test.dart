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
  group('Vector Set - Attributes & Retrieval', () {
    late KeyscopeClient client;

    setUp(() async {
      client = KeyscopeClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.disconnect();
    });

    test('Attributes Management (VSETATTR, VGETATTR)', () async {
      const key = 'vec:products';
      const id = 'prod:1';

      // Add vector
      await client.vAdd(key, [0.9, 0.1], id);

      // 1. VSETATTR

      // Pass attributes as a Map
      // Set attributes using a Map
      await client.vSetAttr(
        key,
        id,
        {
          // Set metadata attribute 'category' = 'electronics'
          'category': 'electronics',
          // Set numeric attribute 'price' = 100
          'price': 100
        },
      );

      // 2. VGETATTR
      // Retrieve attributes (returns Map)
      final attrs = await client.vGetAttr(key, id) as Map<String, dynamic>?;

      expect(attrs, isNotNull);
      expect(attrs?['category'], equals('electronics'));
      // Redis might treat numbers in JSON as int or double, handle flexibly
      // Handle potential type differences (int vs double vs string) gracefully
      expect(attrs?['price'].toString(), equals('100'));
    });

    test('Embedding & Random Member (VEMB, VRANDMEMBER)', () async {
      // Use a unique key name to avoid "Quantization mismatch"
      // with debris from previous failed runs (which might be Q8).
      // Use a clean key
      const key = 'vec:data:noquant';

      // Ensure clean slate explicitly for this key
      // try { await client.del([key]); } catch (_) {}

      final vectorData = [0.5, 0.5, 0.5];

      // VADD with NOQUANT
      // Added `noQuant: true` to prevent 8-bit quantization loss
      await client.vAdd(
        key,
        vectorData,
        'id:1',
        // Create with Float32 precision (Use Float32 precision)
        noQuant: true, // Important for exact float retrieval
      );

      // Add another for randomness check
      await client.vAdd(key, [0.1, 0.1, 0.1], noQuant: true, 'id:2');

      // 1. VEMB (Retrieve vector)
      final emb = await client.vEmb(key, 'id:1');

      // Now this should match exactly
      // Should match exactly because NOQUANT was used
      // expect(emb, equals(vectorData)); // Should match inserted list

      // Use fuzzy comparison instead of strict equality
      // Float32 (Redis) vs Float64 (Dart) conversion can cause tiny differences
      // like 0.5 vs 0.49999997...
      expectVectorsClose(emb, vectorData);

      // 2. VRANDMEMBER
      // Get 1 random member
      final rand = await client.vRandMember(key);
      expect(rand, isNotNull);

      // Get 2 random members
      final randList = await client.vRandMember(key, count: 2);
      expect(randList, isA<List>());
      expect((randList as List).length, equals(2));
    });
  });
}

// [Helper] Function to compare vectors with a tolerance (delta)
void expectVectorsClose(List<dynamic> actual, List<num> expected,
    {double delta = 1e-4}) {
  expect(actual.length, equals(expected.length),
      reason: 'Vector length mismatch');
  for (var i = 0; i < actual.length; i++) {
    expect(actual[i], closeTo(expected[i], delta),
        reason: 'Vector mismatch at index $i: '
            'expected ${expected[i]} but got ${actual[i]}');
  }
}
