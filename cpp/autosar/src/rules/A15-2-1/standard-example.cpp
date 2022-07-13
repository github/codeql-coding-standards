//% $Id: A15-2-1.cpp 271927 2017-03-24 12:01:35Z piotr.tanski $
#include <cstdint>
#include <stdexcept>
class A {
public:
  A() noexcept : x(0) {
    // ...
  }
  explicit A(std::int32_t n) : x(n) {
    // ...
    throw std::runtime_error("Unexpected error");
  }
  A(std::int32_t i, std::int32_t j) noexcept : x(i + j) {
    try {
      // ...
      throw std::runtime_error("Error");
      // ...
    }

    catch (std::exception &e) {
    }
  }

private:
  std::int32_t x;
};
static A a1;    // Compliant - default constructor of type A is noexcept
static A a2(5); // Non-compliant - constructor of type A throws, and the
                // exception will not be caught by the handler in main function
static A a3(5, 10); // Compliant - constructor of type A is noexcept, it
                    // handles exceptions internally
int main(int, char **) {
  try {
    // program code
  } catch (...) {
    // Handle exceptions
  }

  return 0;
}