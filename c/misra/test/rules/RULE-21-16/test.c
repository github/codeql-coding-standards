#include <stdbool.h>
#include <string.h>

void testMemcmpSignedInt(signed int *p, signed int *q, size_t size) {
  memcmp(p, q, size); // COMPLIANT
}

void testMemcmpUnsignedInt(unsigned int *p, unsigned int *q, size_t size) {
  memcmp(p, q, size); // COMPLIANT
}

enum E1 { E1_1, E1_2 };

void testMemcmpEnum(enum E1 *p, enum E1 *q, size_t size) {
  memcmp(p, q, size); // COMPLIANT
}

void testMemcmpBool(bool *p, bool *q, size_t size) {
  memcmp(p, q, size); // COMPLIANT
}

void testMemcmpFloat(float *p, float *q, size_t size) {
  memcmp(p, q, size); // NON_COMPLIANT
}

void testMemcmpPointerToPointer(void **p, void **q, size_t size) {
  memcmp(p, q, size); // COMPLIANT
}

struct S1 {
  int i;
};

void testMemcmpStruct(struct S1 *p, struct S1 *q, size_t size) {
  memcmp(p, q, size); // NON_COMPLIANT
}

union U;

void testMemcmpUnion(union U *p, union U *q, size_t size) {
  memcmp(p, q, size); // NON_COMPLIANT
}

void testMemcmpChar(char *p, char *q, size_t size) {
  memcmp(p, q, size); // NON_COMPLIANT
}

void testMemcmpCharArray(char p[10], char q[10], size_t size) {
  memcmp(p, q, size); // NON_COMPLIANT
}

void testMemcmpIntArray(int p[10], int q[10], size_t size) {
  memcmp(p, q, size); // COMPLIANT
}