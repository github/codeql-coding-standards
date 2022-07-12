//% $Id: A15-0-5.cpp 309502 2018-02-28 09:17:39Z michal.szczepankiewicz $
#include <cstdint>
#include <stdexcept>
#include <system_error>

// @checkedException
class CommunicationError
    : public std::exception // Compliant - communication error is "checked"
{
public:
  explicit CommunicationError(const char *message) : msg(message) {}
  CommunicationError(CommunicationError const &) noexcept = default;
  CommunicationError &operator=(CommunicationError const &) noexcept = default;
  ~CommunicationError() override = default;

  const char *what() const noexcept override { return msg; }

private:
  const char *msg;
};

// @checkedException
class BusError : public CommunicationError // Compliant - bus error is "checked"
{
public:
  using CommunicationError::CommunicationError;
};

// @checkedException
class Timeout : public std::runtime_error // Compliant - communication timeout
                                          // is "checked"
{
public:
  using std::runtime_error::runtime_error;
};

// @checkedException
class PreconditionsError : public std::exception // Non-compliant - error on
                                                 // preconditions check should
                                                 // be "unchecked" but is
                                                 // defined to be "checked"
{
  // Implementation
};

void Fn1(std::uint8_t *buffer, std::uint8_t bufferLength) noexcept(false) {
  bool sentSuccessfully = true;

  // ...
  if (!sentSuccessfully) {
    throw CommunicationError(
        "Could not send data"); // Checked exception thrown correctly
  }
}
void Fn2(std::uint8_t *buffer, std::uint8_t bufferLength) noexcept(false) {
  bool initSuccessfully = true;

  if (!initSuccessfully) {
    throw PreconditionsError(); // An exception thrown on preconditions
                                // check failure should be "Unchecked", but
                                // PreconditionsError is "Checked"
  }

  // ...
  bool sentSuccessfully = true;
  bool isTimeout = false;

  // ...
  if (!sentSuccessfully) {
    throw BusError("Could not send data"); // Checked exception thrown correctly
  }

  // ...
  if (isTimeout) {
    throw Timeout("Timeout reached"); // Checked exception thrown correctly
  }
}
void Fn3(std::uint8_t *buffer) noexcept(false) {
  bool isResourceBusy = false;

  // ...
  if (isResourceBusy) {
    throw std::runtime_error(
        "Resource is busy now"); // Checked exception thrown correctly
  }
}
class Thread // Class which mimics the std::thread
{
public:
  // Implementation

  Thread() noexcept(false) {
    bool resourcesAvailable = false;
    // ...
    if (!resourcesAvailable) {
      throw std::system_error(
          static_cast<int>(std::errc::resource_unavailable_try_again),
          std::generic_category()); // Compliant - correct usage of
                                    // checked exception system_error
    }
  }
};