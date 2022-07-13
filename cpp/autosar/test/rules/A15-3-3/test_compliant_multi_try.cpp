#include <exception>

class CustomException {};

void f() { throw CustomException(); }

// WARNING: qltest will effectively link all the test cases together, so each
// `main` needs a unique signature
int main() {
  try {
    f();
  } catch (std::exception &e) { // COMPLIANT - std::exception caught

  } catch (
      CustomException &c) { // COMPLIANT - CustomException is thrown and caught
  }

  try {
    f();
  } catch (std::exception &e) { // COMPLIANT - std::exception caught

  } catch (
      CustomException &c) { // COMPLIANT - CustomException is thrown and caught
  }
  return 0;
}
