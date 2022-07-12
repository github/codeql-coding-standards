void test_dynamic_exception_specification_specific_throw() throw(
    char *) { // NON_COMPLIANT
  throw "";
}

void test_dynamic_exception_specification_no_throw() throw() { // NON_COMPLIANT
}

void test_noexcept() noexcept(true) { // COMPLIANT - noexcept is not deprecated
}

void test() { // COMPLIANT - no exception specification at all
}