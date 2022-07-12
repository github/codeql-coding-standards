#include <exception>

class CustomException {};

class IrrelevantException {};

void f() { throw CustomException(); }

// WARNING: qltest will effectively link all the test cases together, so each
// `main` needs a unique signature
int main(int p1, char *p2[]) try { // NON_COMPLIANT - missing catch handlers for
                                   // CustomException
                                   // and std::exception
  f();
  return 0;
} catch (IrrelevantException &c) {
  return 0;
}
