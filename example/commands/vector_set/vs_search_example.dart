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

Future<void> main() async {
  final client = KeyscopeClient(host: 'localhost', port: 6379);
  await client.connect();
  await client.flushAll();

  print('--- 🔍 Vector Set: Search & Range ---');

  const key = 'vec:search';

  // Setup: Add vectors
  // v1 & v2 are identical (distance 0), v3 is orthogonal
  await client.vAdd(key, [1.0, 0.0], 'v1');
  await client.vAdd(key, [1.0, 0.0], 'v2');
  await client.vAdd(key, [0.0, 1.0], 'v3');

  // 1. VSIM (Similarity Search)
  print('1. Searching similar vectors (VSIM)...');

  // Case A: Query by raw Vector
  final resultsVec = await client.vSim(
    key,
    queryVector: [1.0, 0.0], // Find vectors close to [1, 0]
    withScores: true,
    count: 2,
  );
  print('   Query by Vector results: $resultsVec');
  // Output format: [id1, score1, id2, score2]

  // Case B: Query by existing Element ID
  final resultsId = await client.vSim(
    key,
    queryElement: 'v3', // Find vectors close to 'v3'
    withScores: true,
  );
  print('   Query by ID(v3) results: $resultsId');

  // 2. VRANGE (Lexical Iterator)
  // Note: VRANGE in Redis 8.0 is a LEXICAL iterator, not a radius search.
  print('2. Iterating elements (VRANGE)...');

  // Add more items for iteration
  await client.vAdd(key, [0.5, 0.5], 'apple');
  await client.vAdd(key, [0.5, 0.5], 'banana');

  // Iterate from 'a' to 'c'
  // [apple means inclusive 'apple'
  // (c means exclusive 'c'
  final rangeItems = (await client.vRange(
    key,
    '[apple',
    '(c',
  ) as List<String>)
      .cast<String>();

  print('   Items from "apple" to "c": $rangeItems');
  // Expected: [apple, banana] (sorted lexicographically)

  // 3. VLINKS (Graph Connectivity)
  print('3. Inspecting graph links (VLINKS)...');
  final links = await client.vLinks(key, 'v1');
  print('   Node "v1" connects to: $links');

  await client.disconnect();
}
