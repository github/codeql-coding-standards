#include <iostream>

void f();

void noex() noexcept;

int main() {
  noex();
  try {
    noex();
    f();
  } catch (...) {
    // NON-COMPLIANT: cout can throw and is not within a try block.
    std::cout << "Caught unknown exception" << std::endl;
  }
  noex();
}