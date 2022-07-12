//% $Id: A15-4-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <stdexcept>
// library.h
void LibraryFunc();
// project.cpp
void F1() noexcept {
  // ...
  throw std::runtime_error("Error"); // Non-compliant - f1 declared to be
  // noexcept, but exits with exception.
  // This leads to std::terminate() call
}
void F2() noexcept(true) {
  try {
    // ...
    throw std::runtime_error(
        "Error"); // Compliant - exception will not leave f2
  } catch (std::runtime_error &e) {
    // Handle runtime error
  }
}
void F3() noexcept(false) {
  // ...
  throw std::runtime_error("Error"); // Compliant
}
void F4() noexcept(
    false) // Compliant - no information whether library_func() throws or not
{
  LibraryFunc();
}