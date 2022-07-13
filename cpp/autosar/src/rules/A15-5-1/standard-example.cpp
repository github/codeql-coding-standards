//% $Id: A15-5-1.cpp 309720 2018-03-01 14:05:17Z jan.babst $
#include <stdexcept>
#include <type_traits>
class C1 {
public:
  C1() = default;

  // Compliant - move constructor is non-throwing and declared to be noexcept
  C1(C1 &&rhs) noexcept {}

  // Compliant - move assignment operator is non-throwing and declared to be
  // noexcept
  C1 &operator=(C1 &&rhs) noexcept { return *this; }

  // Compliant - destructor is non-throwing and declared to be noexcept by
  // default
  ~C1() noexcept {}
};

void Swap(C1 &lhs,
          C1 &rhs) noexcept // Compliant - swap function is non-throwing and
                            // declared to be noexcept
{
  // Implementation
}

class C2 {
public:
  C2() = default;

  // Compliant - move constructor is non-throwing and declared to be noexcept
  C2(C2 &&rhs) noexcept {
    try {
      // ...
      throw std::runtime_error(
          "Error"); // Exception will not escape this function
    }

    catch (std::exception &e) {
      // Handle error
    }
  }

  C2 &operator=(C2 &&rhs) noexcept {
    try {
      // ...
      throw std::runtime_error(
          "Error"); // Exception will not escape this function
    }

    catch (std::exception &e) {
      // Handle error
    }
    return *this;
  }

  // Compliant - destructor is non-throwing and declared to be noexcept by
  // default
  ~C2() {
    try {
      // ...
      throw std::runtime_error(
          "Error"); // Exception will not escape this function
    }

    catch (std::exception &e) {
      // Handle error
    }
  }
};

// Non-compliant - swap function is declared to be noexcept(false)
void Swap(C2 &lhs, C2 &rhs) noexcept(false) {
  // ...
  // Non-compliant - Implementation exits with an exception
  throw std::runtime_error("Swap function failed");
}

class C3 {
public:
  C3() = default;
  C3(C3 &&rhs) // Non-compliant - move constructor throws
  {
    // ...
    throw std::runtime_error("Error");
  }
  C3 &operator=(C3 &&rhs) // Non-compliant - move assignment operator throws
  {
    // ...
    throw std::runtime_error("Error");
    return *this;
  }
  ~C3() // Non-compliant - destructor exits with an exception
  {
    throw std::runtime_error("Error");
  }
  static void operator delete(void *ptr, std::size_t sz) {
    // ...
    throw std::runtime_error("Error"); // Non-compliant - deallocation
                                       // function exits with an exception
  }
};

void Fn() {
  C3 c1; // program terminates when c1 is destroyed
  C3 *c2 = new C3;
  // ...
  delete c2; // program terminates when c2 is deleted
}

template <typename T> class Optional {
public:
  // ...

  // Compliant by exception
  Optional(Optional &&other) noexcept(
      std::is_nothrow_move_constructible<T>::value) {
    // ...
  }

  // Compliant by exception
  Optional &operator=(Optional &&other) noexcept(
      std::is_nothrow_move_assignable<T>::value
          &&std::is_nothrow_move_constructible<T>::value) {
    // ...
    return *this;
  }

  // ...
};