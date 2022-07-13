#include <stdexcept>

void throw_nested() {
  try {
    throw "Exception";
  } catch (...) {
    std::throw_with_nested( // COMPLIANT - there is a current exception
        std::runtime_error("Extra context"));
  }
}

void throw_not_nested() {
  std::throw_with_nested( // NON_COMPLIANT - no current exception
      std::runtime_error("Extra context"));
}

int main() {
  try {
    throw_nested();
    throw_not_nested();
  } catch (std::exception &e) {
    std::rethrow_if_nested(e);
  }
}