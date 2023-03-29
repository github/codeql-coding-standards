#include <stddef.h>
#include <stdlib.h>

void *aligned_alloc_wrapper(size_t alignment, size_t size) {
  return aligned_alloc(alignment, size);
}

void *realloc_wrapper(void *ptr, size_t size) { return realloc(ptr, size); }

void test_aligned_alloc_to_realloc(void) {
  void *v1;
  void *v2;
  void *v3;

  v1 = aligned_alloc_wrapper(32, 32);
  v1 = realloc_wrapper(v1, 64); // NON_COMPLIANT - result reported in wrapper
  v1 = realloc(v1, 64);         // COMPLIANT

  v2 = aligned_alloc(16, 16);
  v2 = realloc(v2, 32); // COMPLIANT - alignment unchanged

  v3 = aligned_alloc(32, 16);
  v3 = realloc(v3, 32); // NON_COMPLIANT
}