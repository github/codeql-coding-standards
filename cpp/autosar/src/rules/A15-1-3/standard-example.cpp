//% $Id: A15-1-3.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
static std::string ComposeMessage(const char *file, const char *func,
                                  std::int32_t line,
                                  const std::string &message) noexcept {
  std::stringstream s;
  s << "(" << file << ", " << func << ":" << line << "): " << message;

  return s.str();
}
void F1() {
  // ...
  throw std::logic_error("Error");
}
void F2() {
  // ...
  throw std::logic_error("Error"); // Non-compliant - both exception type and
                                   // error message are not unique
}
void F3() {
  // ...
  throw std::invalid_argument("Error"); // Compliant - exception type is unique
}
void F4() noexcept(false) {
  // ...
  throw std::logic_error("f3(): preconditions were not met"); // Compliant -
                                                              // error
                                                              // message is
                                                              // unique
}
void F5() noexcept(false) {
  // ...
  throw std::logic_error(ComposeMessage(
      __FILE__, __func__, __LINE__,
      "postconditions were not met")); // Compliant - error message is unique
}
void F6() noexcept {
  try {
    F1();
    F2();
    F3();
  }

  catch (std::invalid_argument &e) {
    std::cout << e.what() << ’\n’; // Only f3() throws this type of
                                   // exception, it is easy to deduce which
                                   // function threw
  } catch (std::logic_error &e) {
    std::cout << e.what() << ’\n’; // f1() and f2() throw exactly the same
                                   // exceptions, unable to deduce which
                                   // function threw
  }

  try {
    F4();
    F5();
  }

  catch (std::logic_error &e) {
    std::cout << e.what() << ’\n’; // Debugging process simplified, because
                                   // of unique error message it is known
                                   // which function threw
  }
}