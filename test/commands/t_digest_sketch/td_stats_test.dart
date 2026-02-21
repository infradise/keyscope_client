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
  group('T-Digest - Statistics Operations', () {
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

    testRedis('MIN, MAX, CDF, and QUANTILE', () async {
      const key = 'td:stats';

      // Explicitly create the T-Digest sketch before adding data
      await client.tDigestCreate(key);

      // Add values from 1 to 10
      final values = List<double>.generate(10, (i) => (i + 1).toDouble());
      await client.tDigestAdd(key, values);

      // 1. MIN / MAX
      expect(await client.tDigestMin(key), closeTo(1.0, 0.01));
      expect(await client.tDigestMax(key), closeTo(10.0, 0.01));

      // 2. QUANTILE (p50 = Median)
      final quantiles = await client.tDigestQuantile(key, [0.5]);
      expect(quantiles[0], closeTo(5.5, 0.5)); // Approx median

      // 3. CDF (Fraction <= 5.0)
      final cdf = await client.tDigestCdf(key, [5.0]);
      expect(cdf[0], closeTo(0.5, 0.1)); // Approx 50% are <= 5
    });

    testRedis('RANK, BYRANK, and TRIMMED_MEAN', () async {
      const key = 'td:ranks';

      // Explicitly create the T-Digest sketch
      await client.tDigestCreate(key);

      await client.tDigestAdd(key, [10.0, 20.0, 30.0, 40.0, 50.0]);

      // 1. RANK
      final rank = await client.tDigestRank(key, [30.0]);
      expect(rank[0], equals(2)); // Approx 2 items are < 30 (10, 20)

      // 2. BYRANK
      final byRank = await client.tDigestByRank(key, [0]);
      expect(byRank[0], closeTo(10.0, 0.5)); // Lowest rank

      // 3. TRIMMED_MEAN (Exclude bottom 20% and top 20%)
      final tMean = await client.tDigestTrimmedMean(key, 0.2, 0.8);
      expect(
          tMean, closeTo(30.0, 1.0)); // The middle values (20, 30, 40) average
    });
  });
}
