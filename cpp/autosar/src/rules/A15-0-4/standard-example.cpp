//% $Id: A15-0-4.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <stdexcept>
#include <vector>
class InvalidArguments : public std::logic_error // Compliant - invalid
                                                 // arguments error is
                                                 // "unchecked" exception
{
public:
  using std::logic_error::logic_error;
};
class OutOfMemory : public std::bad_alloc

{
public:
  using std::bad_alloc::bad_alloc;
};
Compliant - insufficient memory error is
    "unchecked" exception class DivisionByZero
    : public std::logic_error // Compliant - division by zero
// error is "unchecked"
// exception

{
public:
  using std::logic_error::logic_error;
};

class CommunicationError : public std::logic_error // Non-compliant -
                                                   // communication error
                                                   // should be "checked"
// exception but defined to be "unchecked"
{
public:
  using std::logic_error::logic_error;
};
double Division(std::int32_t a, std::int32_t b) noexcept(false) {
  // ...
  if (b == 0) {
    throw DivisionByZero(
        "Division by zero error"); // Unchecked exception thrown correctly
  }

  // ...
}
void Allocate(std::uint32_t bytes) noexcept(false) {
  // ...
  throw OutOfMemory(); // Unchecked exception thrown correctly
}
void InitializeSocket() noexcept(false) {
  bool validParameters = true;

  // ...
  if (!validParameters) {
    throw InvalidArguments("Invalid parameters passed"); // Unchecked
                                                         // exception
                                                         // thrown
                                                         // correctly
  }
}
void SendData(std::int32_t socket) noexcept(false) {
  // ...
  bool isSentSuccessfully = true;

  // ...
  if (!isSentSuccessfully) {
    throw CommunicationError("Could not send data"); // Unchecked exception
                                                     // thrown when checked
                                                     // exception should
                                                     // be.
  }
}
void IterateOverContainer(const std::vector<std::int32_t> &container,
                          std::uint64_t length) noexcept(false) {
  for (std::uint64_t idx{0U}; idx < length; ++idx) {
    int32_t value = container.at(idx); // at() throws std::out_of_range
                                       // exception when passed integer
                                       // exceeds the size of container.
                                       // Unchecked exception thrown
                                       // correctly
  }
}