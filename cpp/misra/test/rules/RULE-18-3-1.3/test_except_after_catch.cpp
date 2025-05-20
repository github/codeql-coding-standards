#include <iostream>

void f();

void noex() noexcept;

int main() {
  noex();
  try {
    noex();
    f();
  } catch (...) {
    noex();
  }
  // NON-COMPLIANT: f() can throw and is outside of the try-catch(...) block.
  f();
}