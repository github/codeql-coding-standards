//% $Id: A15-4-5.cpp 309502 2018-02-28 09:17:39Z michal.szczepankiewicz $
#include <cstdint>
#include <stdexcept>

/// @checkedException
class CommunicationError : public std::exception {
  // Implementation
};
/// @checkedException
class BusError : public CommunicationError {
  // Implementation
};
/// @checkedException
class Timeout : public std::runtime_error {
public:
  using std::runtime_error::runtime_error;
  // Implementation
};
/// @throw CommunicationError Communication error
/// @throw BusError Bus error
/// @throw Timeout On send timeout exception
void Send1(std::uint8_t *buffer,
           std::uint8_t bufferLength) noexcept(false) // Compliant - All and
                                                      // only those checked
                                                      // exceptions that can be
                                                      // thrown are specified
{
  // ...
  throw CommunicationError();
  // ...
  throw BusError();
  // ...
  throw Timeout("Timeout reached");
  // ...
}
/// @throw CommunicationError Communication error
void Send2(std::uint8_t *buffer,
           std::uint8_t bufferLength) noexcept(false) // Non-compliant - checked
                                                      // exceptions that can be
                                                      // thrown are missing from
                                                      // specification
{
  // ...
  throw CommunicationError();
  // ...
  throw Timeout("Timeout reached");
  // ...
}
class MemoryPartitioningError : std::exception {
  // Implementation
};
/// @throw CommunicationError Communication error
/// @throw BusError Bus error
/// @throw Timeout On send timeout exception
/// @throw MemoryPartitioningError Memory partitioning error prevents message
/// from being sent.
void Send3(
    std::uint8_t *buffer,
    std::uint8_t bufferLength) noexcept(false) // Non-compliant - additional
                                               // checked exceptions are
                                               // specified
{
  // ...
  throw CommunicationError();
  // ...
  throw Timeout("Timeout reached");
  // ...
}