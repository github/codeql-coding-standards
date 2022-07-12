#include <stdlib.h>

void test_malloc_calloc_free() {
  char *p1, *p2;
  // the following should all fail check:
  p1 = (char *)malloc(10 * sizeof(char));
  p2 = (char *)calloc(10, sizeof(char));
  p2 = (char *)realloc(p2, 25);

  // you'll get two failures here:
  free(p1);
  free(p2);

  // this should succeed because it's new & delete
  char *q;
  q = new char[10];
  delete[] q;
}