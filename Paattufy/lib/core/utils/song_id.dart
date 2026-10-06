/// Stable song identity that survives rescans: a hash of the MediaStore id and
/// the file path (TP §4.1). FNV-1a 64-bit (wrapping arithmetic), hex-encoded.
String songIdFor(int mediaStoreId, String filePath) {
  const int fnvOffset = 0xcbf29ce484222325; // wraps to a negative int64; fine
  const int fnvPrime = 0x100000001b3;
  var hash = fnvOffset;
  for (final unit in '$mediaStoreId|$filePath'.codeUnits) {
    hash ^= unit;
    hash *= fnvPrime;
  }
  final hi = (hash >>> 32) & 0xFFFFFFFF;
  final lo = hash & 0xFFFFFFFF;
  return hi.toRadixString(16).padLeft(8, '0') +
      lo.toRadixString(16).padLeft(8, '0');
}
