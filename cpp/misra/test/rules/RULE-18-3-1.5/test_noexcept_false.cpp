#include <iostream>

void f() noexcept(false);

void noex() noexcept;

int main() {
  f(); // NON-COMPLIANT: f() can throw and is outside of the try-catch(...)
       // block.
  try {
    f();
    noex();
  } catch (...) {
    noex();
  }
  noex();
}