
class ExceptionA {};

void test_throw() noexcept(true) {
  throw ExceptionA(); // NON_COMPLIANT - function marked as noexcept(true)
}

void throwA() { throw ExceptionA(); }

void test_indirect_throw() noexcept(true) {
  throwA(); // NON_COMPLIANT - function marked as noexcept(true)
}

void test_indirect_throw_2() noexcept {
  throwA(); // NON_COMPLIANT - function marked as noexcept(true)
}

void test_indirect_throw_3() noexcept(false) {
  throwA(); // COMPLIANT - function marked as noexcept(false)
}

void test_indirect_throw_4() {
  throwA(); // COMPLIANT - function marked as noexcept(false)
}