#include <cstddef>

typedef struct PodTag {
  int i;
  double d;
  char c;
} PodType;

void test_offsetof() { int x = offsetof(PodType, c); }