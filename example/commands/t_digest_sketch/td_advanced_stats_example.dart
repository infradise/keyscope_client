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

  print('--- 🔬 T-Digest Advanced Statistical Analysis ---');

  const key = 'metrics:daily_revenue';

  // Initialize the T-Digest sketch
  print('0. Creating T-Digest...');
  await client.tDigestCreate(key);

  // Insert mock daily revenue data including some outliers
  print('   Adding daily revenue data...');
  await client.tDigestAdd(key, [
    100.0, 110.0, 105.0, 115.0, // Normal days
    5000.0, 10.0 // Outliers (Black Friday & Outage)
  ]);

  // 1. CDF (Cumulative Distribution Function)
  print('1. Analyzing CDF...');
  // What fraction of days had revenue <= 120.0?
  final cdf = await client.tDigestCdf(key, [120.0]);
  print('   Fraction of days with revenue <= 120: '
      '${(cdf[0] * 100).toStringAsFixed(1)}%');

  // 2. Trimmed Mean (Robust Mean excluding outliers)
  print('2. Calculating Trimmed Mean...');
  // Exclude the bottom 10% and top 10% of values
  final robustMean = await client.tDigestTrimmedMean(key, 0.1, 0.9);
  print('   Trimmed Mean (excluding extreme outliers): '
      '\$${robustMean.toStringAsFixed(2)}');

  // 3. Rank & ByRank
  print('3. Ranking Analysis...');
  // How many days had revenue less than the 5000 outlier?
  final rankList = await client.tDigestRank(key, [5000.0]);
  print('   Number of observations smaller than 5000: ${rankList[0]}');

  // What is the value at rank 0 (the absolute minimum)?
  final byRankList = await client.tDigestByRank(key, [0]);
  print('   Value at Rank 0 (Minimum): \$${byRankList[0]}');

  await client.disconnect();
  print('\n--- Done ---');
}
