#include <exception>

class CustomException {};

void f() { throw CustomException(); }

// WARNING: qltest will effectively link all the test cases together, so each
// `main` needs a unique signature
int main(int p1, char *p2[], char *p3[]) {
  try {
    f();
  } catch (std::exception &e) { // COMPLIANT - std::exception caught

  } catch (
      CustomException &c) { // COMPLIANT - CustomException is thrown and caught
  }

  try {
    f();                        // NON_COMPLIANT - CustomException not caught
  } catch (std::exception &e) { // COMPLIANT - std::exception caught
  }

  try {
    f();
  } catch (
      CustomException &c) { // COMPLIANT - CustomException is thrown and caught
  }                         // NON_COMPLIANT - std::exception not caught

  return 0;
}
