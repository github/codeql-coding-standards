// semmle-extractor-options: --microsoft

__declspec(allocator) void *malloc5(int b) { // NON_COMPLIANT
  return nullptr;
}