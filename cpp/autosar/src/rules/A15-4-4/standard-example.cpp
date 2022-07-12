//% $Id: A15-4-4.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <iostream>
#include <stdexcept>
void F1(); // Compliant - f1, without noexcept specification, declares to throw
// exceptions implicitly
void F2() noexcept;        // Compliant - f2 does not throw exceptions
void F3() noexcept(true);  // Compliant - f3 does not throw exceptions
void F4() noexcept(false); // Compliant - f4 declares to throw exceptions
void F5() noexcept         // Compliant - f5 does not throw exceptions
{
  try {
    F1(); // Exception handling needed, f1 has no noexcept specification
  }

  catch (std::exception &e) {
    // Handle exceptions
  }

  F2(); // Exception handling not needed, f2 is noexcept
  F3(); // Exception handling not needed, f3 is noexcept(true)

  try {
    F4(); // Exception handling needed, f4 is noexcept(false)
  }

  catch (std::exception &e) {
    // Handle exceptions
  }
}
template <class T>
void F6() noexcept(noexcept(T())); // Compliant - function f6() may be
                                   // noexcept(true) or noexcept(false)
                                   // depending on constructor of class T
template <class T> class A {
public:
  A()
  noexcept(noexcept(T())) // Compliant - constructor of class A may be
  // noexcept(true) or noexcept(false) depending on
  // constructor of class T
  {}
};
class C1 {
public:
  C1()
  noexcept(
      true) // Compliant - constructor of class C1 does not throw exceptions
  {}
  // ...
};
class C2 {
public:
  C2() // Compliant - constructor of class C2 throws exceptions
  {}
  // ...
};
void F7() noexcept // Compliant - f7 does not throw exceptions
{
  std::cout << noexcept(A<C1>()) << ’\n’; // prints ’1’ - constructor of
                                          // A<C1> class is noexcept(true)
  // because constructor of C1 class
  // is declared to be noexcept(true)
  std::cout << noexcept(A<C2>()) << ’\n’; // prints ’0’ - constructor of
                                          // A<C2> class is noexcept(false)
                                          // because constructor of C2 class
                                          // has no noexcept specifier
}