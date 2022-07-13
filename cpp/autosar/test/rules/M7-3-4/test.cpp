#include <string>

using fPointer2 = int (*)(int); // COMPLIANT - using as a type alias

void test_using() {
  using namespace std; // NON_COMPLIANT

  string s{"hello"};
}
