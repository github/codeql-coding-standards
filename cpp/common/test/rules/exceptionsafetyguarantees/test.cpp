#include <cstdint>
#include <cstring>
#include <stdexcept>
class C1 {
public:
  C1(const C1 &rhs) {
    CopyBad(rhs);
    CopyGood(rhs);
  }
  ~C1() { delete[] e; }
  void CopyBad(const C1 &rhs) {
    if (this != &rhs) {
      delete[] e;
      e = nullptr; // e changed before possible throw
      s = rhs.s;   // s changed before possible throw
      if (s > 0) {
        e = new int[s]; // NON_COMPLIANT
        std::memcpy(e, rhs.e, s * sizeof(int));
      }
    }
  }
  void CopyGood(const C1 &rhs) {
    int *eTmp = nullptr;

    if (rhs.s > 0) {
      eTmp = new int[rhs.s];
      std::memcpy(eTmp, rhs.e, rhs.s * sizeof(int));
    }
    delete[] e;
    e = eTmp;
    s = rhs.s;
  }

private:
  int *e;
  unsigned int s;
};

class A {
public:
  A() = default;
};

class C2 {
public:
  C2()
      : a1(new A), // a1 changed before possible throw
        a2(new A)  // NON_COMPLIANT
  {}

private:
  A *a1;
  A *a2;
};

class C3 {
public:
  C3()
      : a1(new A) // a1 changed before possible throw
  {
    new A;      // NON_COMPLIANT
    a2 = new A; // NON_COMPLIANT
  }

private:
  A *a1;
  A *a2;
};

class C4 {
public:
  C4() : a1(nullptr), a2(nullptr) {
    try {
      a1 = new A; // COMPLIANT
      a2 = new A;
    }

    catch (...) {
      delete a1;
      a1 = nullptr;
      delete a2;
      a2 = nullptr;
      throw;
    }
  }

private:
  A *a1;
  A *a2;
};

struct MyStruct {
  int x;
};
void test_recursive(int x) {
  while (x) {
    MyStruct s;
    s.x = 0;
    s.x = 1;
    new int(1); // COMPLIANT
  }
}
