#include <iostream>

void f();

void noex() noexcept;
void noex2() noexcept(true);

int main() {
  noex();
  noex2();
  try {
    noex();
    noex2();
    f();
  } catch (...) {
    try {
      noex();
      noex2();
      std::cout << "Caught unknown exception" << std::endl;
    } catch (...) {
      // COMPLIANT: All exceptions caught via catch(...), even exceptions from
      // cout.
      noex();
      noex2();
    }
  }
  noex();
  noex2();
}