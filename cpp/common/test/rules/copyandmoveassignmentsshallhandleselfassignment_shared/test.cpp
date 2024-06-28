#include <iostream>
#include <string>
#include <utility>

class A {
public:
  A(const A &oth) {}
  A(const A &&oth) noexcept {}
  A &operator=(const A &oth) { // COMPLIANT

    A tmp(oth);
    Swap(*this, tmp);
    return *this;
  }
  A &operator=(A &&oth) noexcept { // COMPLIANT
    A tmp(std::move(oth));
    Swap(*this, tmp);
    return *this;
  }

  static void Swap(A &lhs, A &rhs) noexcept { std::swap(lhs.nPtr, rhs.nPtr); }

private:
  int *nPtr = nullptr;
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

class D {
public:
  D &operator=(const D &oth) // NON_COMPLIANT
  {

    int *tmpPtr = new int(*(oth.nPtr));
    delete nPtr;
    nPtr = tmpPtr;

    return *this;
  }

  D &operator=(D &&oth) noexcept = delete; // COMPLIANT

private:
  int *nPtr = nullptr;
};
