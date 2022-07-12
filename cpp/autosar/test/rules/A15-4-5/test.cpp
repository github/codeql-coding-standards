#include <stdexcept>

/*
 * @checkedException
 */
class CheckedException : public std::exception {};

/*
 * @checkedException
 */
class CheckedException2 : public std::exception {};

/**
 * @throw CheckedException
 */
void test_throws_and_declares() { // COMPLIANT
  throw CheckedException();
}

void test_throws_no_declare() { // NON_COMPLIANT
  throw CheckedException();
}

/**
 * @throw CheckedException2
 */
void test_throws_missing_declare(
    int x) { // NON_COMPLIANT - missing throw to CheckedException
  if (x < 0) {
    throw CheckedException2();
  } else {
    throw CheckedException();
  }
}

/**
 * @throw CheckedException
 */
void test_decl_inconsistent();

void test_decl_inconsistent() { // NON_COMPLIANT - missing CheckedException
                                // throw declaration
  throw CheckedException();
}