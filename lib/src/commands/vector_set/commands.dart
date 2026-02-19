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

import 'dart:typed_data';

import '../commands.dart' show Commands;

export 'extensions.dart';

mixin VectorSetCommands on Commands {
  /// Converts a `List<num>` to a Float32 Little Endian Byte Array (Blob).
  Uint8List packVector(List<num> vector) {
    final bytes = Uint8List(vector.length * 4);
    final view = ByteData.view(bytes.buffer);
    for (var i = 0; i < vector.length; i++) {
      view.setFloat32(i * 4, vector[i].toDouble(), Endian.little);
    }
    return bytes;
  }

  /// Converts a Byte Array (or `List<int>`) back to `List<double>`.
  List<double> unpackVector(List<int> bytes) {
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    final count = byteData.lengthInBytes ~/ 4;
    final vector = <double>[];
    for (var i = 0; i < count; i++) {
      vector.add(byteData.getFloat32(i * 4, Endian.little));
    }
    return vector;
  }
}
