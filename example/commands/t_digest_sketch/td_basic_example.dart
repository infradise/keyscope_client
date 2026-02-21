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

  // Redis Only Feature
  if (!await client.isRedis) {
    print('⚠️  Skipping: This example requires a Redis server.');
    print('   Current server appears to be Valkey or other compatible server.');
    await client.disconnect();
    return;
  }

  await client.flushAll();

  print('--- 📈 T-Digest Basic Setup & Quantiles ---');

  const key = 'metrics:response_time';

  // 1. Initialize
  print('1. Creating T-Digest...');
  await client.tDigestCreate(key, compression: 100);

  // 2. Add Data (e.g., API response times in ms)
  print('2. Adding response time observations...');
  final data = [45.5, 48.0, 51.2, 49.9, 120.0, 47.1, 46.8];
  await client.tDigestAdd(key, data);

  // 3. Query Min / Max
  print('3. Fetching bounds...');
  print('   Min response time: ${await client.tDigestMin(key)} ms');
  print('   Max response time: ${await client.tDigestMax(key)} ms');

  // 4. Query Quantiles (p50, p90, p99)
  print('4. Fetching Quantiles (Median, p90, p99)...');
  final quantiles = await client.tDigestQuantile(key, [0.5, 0.9, 0.99]);
  print('   p50 (Median): ${quantiles[0]} ms');
  print('   p90: ${quantiles[1]} ms');
  print('   p99: ${quantiles[2]} ms');

  await client.disconnect();
  print('\n--- Done ---');
}
