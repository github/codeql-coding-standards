#include <iostream>
void f() noexcept(false);

void noex() noexcept;

int main() {
  noex();
  try {
    f();
  } catch (int x) {
    // NON-COMPLIANT: No catch(...) handler.
    noex();
  }
}