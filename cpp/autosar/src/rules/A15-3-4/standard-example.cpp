//% $Id: A15-3-4.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <stdexcept>
#include <thread>
extern std::int32_t Fn(); // Prototype of external third-party library function
void F1() noexcept(false) {
  try {
    std::int32_t ret = Fn();
    // ...
  }

  // ...
  catch (...) // Compliant
  {
    // Handle all unexpected exceptions from fn() function
  }
}
void F2() noexcept(false) {
  std::int32_t ret =
      Fn(); // Non-compliant - can not be sure whether fn() throws or not

  if (ret < 10) {
    throw std::underflow_error("Error");
  }

  else if (ret < 20) {
    // ...
  } else if (ret < 30) {
    throw std::overflow_error("Error");
  }

  else {
    throw std::range_error("Error");
  }
}
void F3() noexcept(false) {
  try {
    F2();
  }

  catch (std::exception &e) // Non-compliant - caught exception is too
                            // general, no information which error occured
  {
    // Nothing to do
    throw;
  }
}
void F4() noexcept(false) {
  try {
    F3();
  }

  catch (...) // Non-compliant - no information about the exception
  {
    // Nothing to do
    throw;
  }
}
class ExecutionManager {
public:
  ExecutionManager() = default;
  void Execute() noexcept(false) {
    try {
      F3();
    }

    // ...
    catch (std::exception &e) // Compliant
    {
      // Handle all expected exceptions
    } catch (...) // Compliant
    {
      // Handle all unexpected exceptions
    }
  }
};
void ThreadMain() noexcept {
  try {
    F3();
  }

  // ...
  catch (std::exception &e) // Compliant
  {
    // Handle all expected exceptions
  } catch (...) // Compliant
  {
    // Handle all unexpected exceptions
  }
}
int main(int, char **) {
  try {
    ExecutionManager execManager;
    execManager.Execute();
    // ...
    std::thread t(&ThreadMain);
    // ...
    F4();
  }

  // ...
  catch (std::exception &e) // Compliant
  {
    // Handle all expected exceptions
  } catch (...) // Compliant
  {
    // Handle all unexpected exceptions
  }

  return 0;
}