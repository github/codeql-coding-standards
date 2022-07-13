//% $Id: A15-5-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdlib>
#include <exception>
void F1() noexcept(false);
void F2() // Non-compliant
{
  F1(); // A call to throwing f1() may result in an implicit call to
  // std::terminate()
}
void F3() // Compliant
{
  try {
    F1(); // Handles all exceptions from f1() and does not re-throw
  } catch (...) {
    // Handle an exception
  }
}
void F4(const char *log) {
  // Report a log error
  // ...
  std::exit(0); // Call std::exit() function which safely cleans up resources
}
void F5() // Compliant by exception
{
  try {
    F1();
  } catch (...) {
    F4("f1() function failed");
  }
}
int main(int, char **) {
  if (std::atexit(&F2) != 0) {
    // Handle an error
  }

  if (std::atexit(&F3) != 0) {
    // Handle an error
  }

  // ...
  return 0;
}