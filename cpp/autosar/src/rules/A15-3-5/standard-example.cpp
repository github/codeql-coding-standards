//% $Id: A15-3-5.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <iostream>
#include <stdexcept>
class Exception : public std::runtime_error {
public:
  using std::runtime_error::runtime_error;
  const char *what() const noexcept(true) override {
    return "Exception error message";
  }
};
void Fn() {
  try {
    // ...
    throw std::runtime_error("Error");
    // ...
    throw Exception("Error");
  }

  catch (const std::logic_error &e) // Compliant - caught by const reference
  {
    // Handle exception
  } catch (std::runtime_error &e) // Compliant - caught by reference
  {
    std::cout << e.what() << "\n"; // "Error" or "Exception error message"
    // will be printed, depending upon the
    // actual type of thrown object
    throw e; // The exception re-thrown is of its original type
  }

  catch (std::runtime_error
             e) // Non-compliant - derived types will be caught as the base type
  {
    std::cout << e.what()
              << "\n"; // Will always call what() method from std::runtime_error
    throw e; // The exception re-thrown is of the std::runtime_error type,
             // not the original exception type
  }
}