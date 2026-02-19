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

  print('--- 📐 Vector Set: Basic Lifecycle ---');

  // [Setup] Define two separate keys
  const keyDefault = 'vec:users'; // Default (8-bit Quantization)

  // High Precision (Float32, No Quantization)
  const keyPrecision = 'vec:users:precise';

  // 1. VADD (Add Vectors)
  print('1. Adding vectors...');

  // A. Add to Default Key - 8-bit Quantization(Q8)
  // ID is now a required positional argument
  await client.vAdd(keyDefault, [0.1, 0.2, 0.3], 'user:1');
  await client.vAdd(keyDefault, [0.4, 0.5, 0.6], 'user:2');
  print('   [Default] Added 2 vectors to $keyDefault');

  // B. Add to Precision Key (noQuant: true)
  // Add with options (No Quantization for precision)
  // This demonstrates creating a set specifically for high-precision needs
  print('   Adding vector with High Precision (Float32)...');
  await client.vAdd(
    keyPrecision,
    [0.7, 0.8, 0.9],
    'user:100',
    noQuant: true, // Force Float32 storage
  );
  print('   [Precision] Added 1 vector to $keyPrecision (Float32)');

  // 2. VCARD (Count Validation)
  print('2. Validating Counts...');
  final countDefault = await client.vCard(keyDefault);
  final countPrecision = await client.vCard(keyPrecision);

  // Total vectors
  print('   $keyDefault count: $countDefault'); // Expected: 2
  print('   $keyPrecision count: $countPrecision'); // Expected: 1

  // 3. VDIM (Dimension Check)
  final dim = await client.vDim(keyDefault);
  print('3. Vector Dimension (Default Key): $dim');

  // 4. VINFO (Information Inspection)
  print('4. Inspecting Vector Set Info...');
  // Inspecting the precision key to confirm it exists and has properties
  final infoPrecision = await client.vInfo(keyPrecision);
  print('   [Precision Key Info]: $infoPrecision');
  final infoDefault = await client.vInfo(keyDefault);
  print('   [Default Key Info]: $infoDefault');

  // 5. VISMEMBER & VREM (Lifecycle Management)
  print('5. Managing Members...');

  // Check & Delete
  //
  // Check membership in default key
  final exists = await client.vIsMember(keyDefault, 'user:1');
  print('   Is user:1 (member?) in default set? $exists');

  if (exists) {
    await client.vRem(keyDefault, 'user:1');
    print('   Deleted user:1 from default set.');
  }

  // Cleanup: Delete the precision key as well
  await client.del([keyPrecision]);
  print('   Cleaned up precision key.');

  await client.disconnect();
  print('--- Done ---');
}
