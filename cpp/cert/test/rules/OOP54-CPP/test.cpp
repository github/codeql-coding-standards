#include <functional>
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
  A &operator=(A &&oth) noexcept { // compliant
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
  B &operator=(const B &oth) // COMPLIANT
  {
    if (this != &oth) {
      int *tmpPtr = new int(*(oth.nPtr));
      delete nPtr;
      nPtr = tmpPtr;
    }

    return *this;
  }
  B &operator=(B &&oth) noexcept { // COMPLIANT
    if (this != &oth) {
      int *tempPtr = new int(*(std::move(oth.nPtr)));
      delete nPtr;
      nPtr = tempPtr;
    }

    return *this;
  }

private:
  int *nPtr = nullptr;
};

class C {
public:
  C &operator=(const C &oth) // NON_COMPLIANT
  {

    int *tmpPtr = new int(*(oth.nPtr));
    delete nPtr;
    nPtr = tmpPtr;

    return *this;
  }
  C &operator=(C &&oth) noexcept { // NON_COMPLIANT

    int *tempPtr = new int(*(std::move(oth.nPtr)));
    delete nPtr;
    nPtr = tempPtr;

    return *this;
  }

private:
  int *nPtr = nullptr;
};
