
class ExceptionA {};

void test_throw() noexcept(true) {
  throw ExceptionA(); // NON_COMPLIANT - function marked as noexcept(true)
}

void throwA() { throw ExceptionA(); }
void indirectThrowA() { throwA(); }
void noexceptIndirectThrowA() noexcept { throwA(); } // NON_COMPLIANT

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

void test_indirect_throw_5() noexcept {
  noexceptIndirectThrowA(); // COMPLIANT - noexceptIndirectThrowA would call
                            // std::terminate() if ExceptionA is thrown
}

void test_indirect_throw_6() noexcept {
  indirectThrowA(); // NON_COMPLIANT
}