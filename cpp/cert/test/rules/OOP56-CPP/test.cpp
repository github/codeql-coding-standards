#include <exception>
#include <new>
#include <stdlib.h>

void exit_wrapper() { exit(1); }

void abort_wrapper() { abort(); }

void h1() {}

void h2() {
  if (1) {
    throw std::bad_alloc();
  }
}

void h3() {}
void h4() { exit(1); }
void h5() { abort(); }

void h6() {
  if (1) {
    throw std::exception();
  }
}

void h7() { exit_wrapper(); }
void h8() { abort_wrapper(); }

int a;

void h9() {
  if (a == 1) {
    throw std::exception();
  }
  throw std::bad_alloc();
}

void m1() {
  std::set_new_handler(h1); // COMPLIANT
}

void m2() {
  std::set_new_handler(h2); // COMPLIANT
}

void m3() {
  std::set_new_handler(h6); // NON_COMPLIANT
}

void m4() {
  std::set_new_handler(h9); // NON_COMPLIANT
}

void m5() {
  std::set_terminate(h3);  // NON_COMPLIANT
  std::set_unexpected(h3); // NON_COMPLIANT
  std::set_terminate(h4);  // COMPLIANT
  std::set_unexpected(h4); // COMPLIANT
  std::set_terminate(h5);  // COMPLIANT
  std::set_unexpected(h5); // COMPLIANT
  std::set_terminate(h7);  // COMPLIANT
  std::set_unexpected(h8); // COMPLIANT
}