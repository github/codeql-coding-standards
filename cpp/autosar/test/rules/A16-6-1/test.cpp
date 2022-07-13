#include <string> //COMPLIANT

const int g = 0;

void f() {
  static_assert(g == 0, "This is a test error message"); // COMPLIANT
}