//% $Id: A15-2-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <fstream>
#include <stdexcept>
class A {
public:
  A() = default;
};
class C1 {
public:
  C1()
  noexcept(false)
      : a1(new A), a2(new A) // Non-compliant - if a2 memory allocation
                             // fails, a1 will never be deallocated
  {}
  C1(A *pA1, A *pA2)
  noexcept
      : a1(pA1), a2(pA2) // Compliant - memory allocated outside of C1
                         // constructor, and no exceptions can be thrown
  {}

private:
  A *a1;
  A *a2;
};
class C2 {
public:
  C2() noexcept(false) : a1(nullptr), a2(nullptr) {
    try {
      a1 = new A;
      a2 = new A; // If memory allocation for a2 fails, catch-block will
                  // deallocate a1
    }

    catch (std::exception &e) {
      throw; // Non-compliant - whenever a2 allocation throws an
             // exception, a1 will never be deallocated
    }
  }

private:
  A *a1;
  A *a2;
};
class C3 {
public:
  C3() noexcept(false) : a1(nullptr), a2(nullptr), file("./filename.txt") {
    try {
      a1 = new A;
      a2 = new A;

      if (!file.good()) {
        throw std::runtime_error("Could not open file.");
      }
    }

    catch (std::exception &e) {
      delete a1;
      a1 = nullptr;
      delete a2;
      a2 = nullptr;
      file.close();
      throw; // Compliant - all resources are deallocated before the
      // constructor exits with an exception
    }
  }

private:
  A *a1;
  A *a2;
  std::ofstream file;
};
class C4 {
public:
  C4() : x(0), y(0) {
    // Does not need to check preconditions here - x and y initialized with
    // correct values
  }
  C4(std::int32_t first, std::int32_t second)
  noexcept(false) : x(first), y(second) {
    CheckPreconditions(x,
                       y); // Compliant - if constructor failed to create a
                           // valid object, then throw an exception
  }
  static void CheckPreconditions(std::int32_t x,
                                 std::int32_t y) noexcept(false) {
    if (x < 0 || x > 1000) {
      throw std::invalid_argument("Preconditions of class C4 were not met");
    }

    else if (y < 0 || y > 1000) {
      throw std::invalid_argument("Preconditions of class C4 were not met");
    }
  }

private:
  std::int32_t x; // Acceptable range: <0; 1000>
  std::int32_t y; // Acceptable range: <0; 1000>
};