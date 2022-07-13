#ifndef TEST_SHARED_H_
#define TEST_SHARED_H_
struct shared_s1 {
  int v1;
}; // COMPLIANT

struct only_test1_s1 {
  int v1;
}; // COMPLIANT

struct only_test2_s1 {
  int v1;
}; // COMPLIANT

struct only_test2_s2 {
  int v1;
}; // NON_COMPLIANT

union shared_u1 {
  int v1;
  float v2;
}; // NON_COMPLIANT

union shared_u2 {
  int v1;
  float v2;
};     // COMPLIANT
#endif // TEST_SHARED_H_