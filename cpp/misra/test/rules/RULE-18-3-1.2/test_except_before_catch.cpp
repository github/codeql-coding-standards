#include <iostream>

void f();

void noex() noexcept;

int main() {
  f(); // NON-COMPLIANT: f() can throw and is outside of the try-catch(...)
       // block.
  try {
    noex();
    f();
  } catch (...) {
    noex();
  }
  noex();
}