//% $Id: A15-0-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>
std::uint8_t ComputeCrc(std::string &msg);
bool IsMessageCrcCorrect1(std::string &message) {
  std::uint8_t computedCRC = ComputeCrc(message);
  std::uint8_t receivedCRC = message.at(0);

  if (computedCRC != receivedCRC) {
    throw std::logic_error(
        "Computed CRC is invalid."); // Non-compliant - CheckMessageCRC()
                                     // was able to perform
    // its task, nothing exceptional about its invalid result
  }

  return true;
}
bool IsMessageCrcCorrect2(std::string &message) {
  bool isCorrect = true;
  std::uint8_t computedCRC = ComputeCrc(message);
  std::uint8_t receivedCRC = message.at(0);

  if (computedCRC != receivedCRC) {
    isCorrect = false; // Compliant - if CRC is not correct, then return "false"
  }

  return isCorrect;
}
void SendData(std::string message) {
  if (message.empty()) {
    throw std::logic_error("Preconditions are not met."); // Compliant -
                                                          // SendData() was
                                                          // not able to
                                                          // perform its
                                                          // task
  }

  bool sendTimeoutReached = false;

  // Implementation
  if (sendTimeoutReached) {
    throw std::runtime_error(
        "Timeout on sending a message has been reached."); // Compliant -
                                                           // SendData()
                                                           // did not
                                                           // perform its
                                                           // task
  }
}
std::int32_t FindIndex(std::vector<std::int32_t> &v, std::int32_t x) noexcept {
  try {
    std::size_t size = v.size();
    for (std::size_t i = 0U; i < size; ++i) {
      if (v.at(i) == x) // v.at() throws an std::out_of_range exception
      {
        throw i; // Non-compliant - nothing exceptional about finding a
        // value in vector
      }
    }
  }

  catch (std::size_t
             foundIdx) // Non-compliant - nothing exceptional about finding a
                       // value in vector
  {
    return foundIdx;
  }

  catch (std::out_of_range
             &e) // Compliant - std::out_of_range error shall be handled
  {
    return -1;
  }

  return -1;
}
bool ReadFile(std::string &filename) noexcept {
  try {
    std::ifstream file(filename, std::ios_base::in);
    if (!file.is_open()) {
      throw std::runtime_error(
          "File cannot be opened"); // Compliant - error on opening a
                                    // file is an exceptional case
    }

    char c = file.get();

    if (!file.good()) {
      throw std::runtime_error(
          "Cannot read from file"); // Compliant - error on reading from
                                    // file is an exceptional case
    }
  }

  catch (std::exception &e) {
    return false;
  }

  return true;
}
void Fn1(std::uint32_t x) // Non-compliant - inefficient and less readable
                          // version than its obvious alternative, e.g. fn2()
// function
{
  try {
    if (x < 10) {
      throw 10;
    }

    // Action "A"
  }

  catch (std::int32_t y) {
    // Action "B"
  }
}
void Fn2(
    std::uint32_t x) // Compliant - the same functionality as fn1() function
{
  if (x < 10) {
    // Action "B"
  } else {
    // Action "A"
  }
}