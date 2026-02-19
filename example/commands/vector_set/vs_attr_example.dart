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

  print('--- 🏷️ Vector Set: Attributes & Embeddings ---');

  const key = 'vec:products';
  const id = 'prod:101';

  // Add vector
  await client.vAdd(key, [0.9, 0.1], id);

  // 1. VSETATTR (Set Attributes)
  print('1. Setting attributes...');
  await client.vSetAttr(
    key,
    id,
    {
      'name': 'Wireless Mouse',
      'price': 29.99,
      'tags': ['electronics', 'peripheral']
    },
  );

  // 2. VGETATTR (Get Attributes)
  print('2. Getting attributes...');
  final attrs = await client.vGetAttr(key, id) as Map<String, dynamic>?;

  if (attrs != null) {
    print('   Name: ${attrs['name']}');
    print('   Price: ${attrs['price']}');
  }

  // 3. VEMB (Get Vector Embedding)
  print('3. Retrieving vector embedding...');
  final embedding = await client.vEmb(key, id);
  print('   Vector: $embedding');

  // 4. VRANDMEMBER (Random Sample)
  print('4. Getting random member...');
  final randomMember = await client.vRandMember(key);
  print('   Random ID: $randomMember');

  await client.disconnect();
}
