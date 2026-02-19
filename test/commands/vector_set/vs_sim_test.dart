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
  group('Vector Set - Similarity & Search', () {
    late KeyscopeClient client;

    setUp(() async {
      client = KeyscopeClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.disconnect();
    });

    test('Vector Similarity (VSIM)', () async {
      const key = 'vec:sim';
      // vAdd arguments: (key, vector, id) - ID is positional
      await client.vAdd(key, [1.0, 0.0], 'v1');
      await client.vAdd(key, [0.0, 1.0], 'v2');

      // Add vectors: v1 and v2 are identical (distance 0, score 1)
      // v3 is orthogonal (distance 1, score 0 approx)
      await client.vAdd(key, [1.0, 0.0], 'v1');
      await client.vAdd(key, [1.0, 0.0], 'v2');
      await client.vAdd(key, [0.0, 1.0], 'v3');

      // 1. VSIM with Vector Query (VALUES)
      // Find neighbors similar to [1.0, 0.0]
      final results = await client.vSim(
        key,
        queryVector: [1.0, 0.0],
        withScores: true,
        count: 3,
      );

      // Expected: v1 and v2 should be top results with score ~1.0
      // Result structure with WITHSCORES: [id1, score1, id2, score2, ...]
      expect(results, isNotEmpty);

      // Helper to find ID in flat list
      final v1Index = results.indexOf('v1');
      final v2Index = results.indexOf('v2');

      expect(v1Index, greaterThanOrEqualTo(0));
      expect(v2Index, greaterThanOrEqualTo(0));

      // Check scores (next element after ID)
      // Note: Redis returns scores as strings usually
      final score1 = double.parse(results[v1Index + 1].toString());
      final score2 = double.parse(results[v2Index + 1].toString());

      expect(score1, closeTo(1.0, 0.001));
      expect(score2, closeTo(1.0, 0.001));

      // 2. VSIM with Element Query (ELE)
      // Find neighbors of 'v3'
      final neighborsOfV3 = await client.vSim(
        key,
        queryElement: 'v3',
        count: 1,
      );

      // v3 is most similar to itself
      expect(neighborsOfV3, contains('v3'));
    });

    test('Lexical Range Iteration (VRANGE)', () async {
      const key = 'vec:iter';

      await client.vAdd(key, [0.1], 'item:2');
      await client.vAdd(key, [0.1], 'item:1');
      await client.vAdd(key, [0.1], 'item:3');

      // VRANGE Iterate from min(-) to max(+)
      final allItems = await client.vRange(
        key,
        '-',
        '+',
      ) as List<String>; // .cast<String>()

      expect(allItems.length, equals(3));
      // Lexicographical order: item:1, item:2, item:3
      expect(allItems[0], equals('item:1'));
      expect(allItems[1], equals('item:2'));
      expect(allItems[2], equals('item:3'));
    });

    test('Graph Connectivity (VLINKS)', () async {
      const key = 'vec:links';
      await client.vAdd(key, [0.5, 0.5], 'node1');

      final links = await client.vLinks(key, 'node1');
      expect(links, isNotNull);
    });
  });
}
