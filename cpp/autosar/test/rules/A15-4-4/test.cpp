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

#include <utility>
template <typename TypeA, typename TypeB>
void swap_wrapper(TypeA lhs,
                  TypeB rhs) noexcept(noexcept(std::swap(*lhs, *rhs))) {
  std::swap(*lhs, *rhs);
}

void test_swap_wrapper() noexcept {
  int a = 0;
  int b = 1;
  swap_wrapper(&a, &b);
}

#include <stdexcept>
#include <string>

std::string test_fp_reported_in_424(
    const std::string &s1,
    const std::string &s2) { // COMPLIANT - `reserve` and `append` may throw.
  std::string s3;
  s3.reserve(s1.size() + s2.size());
  s3.append(s1.c_str(), s1.size());
  s3.append(s2.c_str(), s2.size());
  return s3;
}

void test_no_except_deviated_decl(); // a-15-4-4-deviation

void test_no_except_deviated_decl() {}

void test_no_except_deviated_defn();

void test_no_except_deviated_defn() {} // a-15-4-4-deviation