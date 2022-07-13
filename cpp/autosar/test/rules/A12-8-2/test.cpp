// #include "utility"
#include <iostream>
#include <string>
#include <utility>

class A {
public:
  A(const A &oth) {}
  A(const A &&oth) noexcept {}
  A &operator=(const A &oth) { // compliant
    A tmp(oth);
    Swap(*this, tmp);
    return *this;
  }
  A &operator=(A &&oth) noexcept { // COMPLIANT
    A tmp(std::move(oth));
    Swap(*this, tmp);
    return *this;
  }
  static void Swap(A &lhs, A &rhs) noexcept {
    std::swap(lhs.ptr1, rhs.ptr1);
    std::swap(lhs.ptr2, rhs.ptr2);
  }

private:
  int *ptr1;
  int *ptr2;
};

class B {
public:
  B &operator=(const B &oth) // NON_COMPLIANT
  {
    if (this != &oth) {
      ptr1 = new int;
      *ptr1 = *(oth.ptr1);
      ptr2 = new int;
      *ptr2 = *(oth.ptr1);
      // a memory leak of ptr1
    }

    return *this;
  }
  B &operator=(B &&oth) noexcept { // NON_COMPLIANT
    if (this != &oth) {
      ptr1 = std::move(oth.ptr1);
      ptr2 = std::move(oth.ptr2);
      oth.ptr1 = nullptr;
      oth.ptr2 = nullptr;
    }

    return *this;
  }

private:
  int *ptr1;
  int *ptr2;
};
