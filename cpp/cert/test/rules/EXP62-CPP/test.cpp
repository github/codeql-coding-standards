#include <string>

struct S1 {
  int i, j, k;

  virtual void f2();
};
// Subclass with base class which has virtual method (vtable)
void f2() {
  S1 *s1 = new S1;

  std::memcpy(s1, 0, sizeof(S1)); // NON_COMPLIANT

  s1->f2(); // underfined behavior
}

struct S2 {
  int i, j, k;

  virtual void f3();
  void clear() { i = j = k = 0; }
};

void f3() {
  S2 *s2 = new S2;

  s2->clear();

  s2->f3(); //  COMPLIANT
}

struct S3 : public S1, public S2 { // Multiple Inheritance
  int i, j, k;
};
// Subclass with base class which has virtual method (vtable )
void f4() {
  S3 *s3 = new S3;

  std::memset(s3, 0, sizeof(S3)); // NON_COMPLIANT

  s3->f3(); //  underfined behavior
}