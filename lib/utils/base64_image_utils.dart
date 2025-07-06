import 'dart:convert';
import 'dart:typed_data';

Uint8List base64ToBytes(String base64String) {
  // Remove data URI prefix if it exists
  final cleanedBase64 = base64String.contains(',')
      ? base64String.split(',').last
      : base64String;

  // Decode and return the bytes
  return base64Decode(cleanedBase64);
}
