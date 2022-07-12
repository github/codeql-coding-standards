#include <iostream>

void f1() { // NON_COMPLIANT
  int i;
  i++;
}

void f2(int *p1) { // COMPLIANT
  (*p1)++;
}

void f3(int &p1) { // COMPLIANT
  p1++;
}

void f4(int p1) { // COMPLIANT
  if (p1 % 2 == 0) {
    throw "even number";
  }
}

void f5(int p1) { // COMPLIANT
  std::cout << p1 << std::endl;
}

int g1 = 0;

void f6() { // COMPLIANT
  g1++;
}

void f7(int *p1) { // COMPLIANT
  p1[0] = p1[1];
}

struct S1 {
  int m1;
  int m2;
};

void f8(struct S1 *p1, int p2, int p3, int p4) { // COMPLIANT
  p1[p2].m1 = p3;
  p1[p2].m2 = p4;
}

S1 g2[] = {{0}, {0}};
void f9(int p1, int p2, int p3) { // COMPLIANT
  g2[p1].m1 = p2;
  g2[p2].m2 = p3;
}

struct S2 {
  S2() { m2 = new int[1]; }
  ~S2() { delete[] m2; }
  int m1[3];
  int *m2;
};

S2 g3;
void f10(int p1, int p2, int p3) { // COMPLIANT
  g3.m1[0] = p1;
  g3.m1[1] = p2;
  g3.m1[2] = p3;
}

void f11(int p1[], int p2) { // COMPLIANT
  p1[0] = p2;
}

void f12(S2 &p1) { // COMPLIANT
  p1.~S2();
}

void f13(S2 *p1) { // COMPLIANT
  p1->~S2();
}

void f14(void *p1) { // COMPLIANT
  S2 *l1 = (S2 *)p1;

  l1->m1[0] = 1;
  l1->m1[1] = 2;
  l1->m1[2] = 3;
}

void f15(int *p1) { // COMPLIANT
  *p1 = 0;
}

void f16(int **p1) { // COMPLIANT
  *p1 = 0;
}

struct S3 {
  int m1;
};

void f17(S3 *p1) { // COMPLIANT
  p1->m1 = 0;
}

struct S4 {
  S3 *m1;
};

void f18(S4 *p1) { // COMPLIANT
  p1->m1->m1 = 0;
}

int *g4;

void f19() { // COMPLIANT
  *g4 = 0;
}

void f20() {
  volatile int l1 = 0;

  l1 = l1 + 1; // COMPLIANT
}