class ExceptionA {};

void test_no_throw() { // NON_COMPLIANT - Should be marked noexcept
}

void test_no_throw_excluded() noexcept(false) { // COMPLIANT - noexcept(false)
                                                // is explicitly specified
}

void test_no_throw_noexcept() noexcept { // COMPLIANT - doesn't throw, and is
                                         // marked noexcept
}

void test_throw() { // COMPLIANT - throws an exception
  throw "";
}

void throwA() { throw ExceptionA(); }

void test_indirect_throw() { // COMPLIANT - throws an exception indirectly
  throwA();
}

class A {
public:
  A() = delete; // COMPLIANT - deleted functions imply `noexcept(true)`.
};

/* Added for testing FP of embedded operator inside lambdas being reported */
void lambda_example() noexcept {
  auto with_capture = [=]() {};
  auto empty_capture = []() {};
}