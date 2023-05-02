#include "test.h"
#include <cstdint>
#include <functional>
#include <string>

#undef INT_MAX       // NON_COMPLIANT
#define SIZE_MAX 256 // NON_COMPLIANT

enum {
  INT_MAX = 0 // NON_COMPLIANT
};

#undef noreturn   // NON_COMPLIANT
#define private 1 // NON_COMPLIANT

// int NULL = 0; // NON_COMPLIANT, but not supported by compilers in practice

int tzname = 0; // NON_COMPLIANT

void min() {} // NON_COMPLIANT

void operator"" x(long double);  // NON_COMPLIANT
void operator"" _x(long double); // COMPLIANT

int __x; // NON_COMPLIANT
int _X;  // NON_COMPLIANT
int _x;  // NON_COMPLIANT
namespace ns {
int _x;  // COMPLIANT
int __x; // NON_COMPLIANT
int _X;  // NON_COMPLIANT
} // namespace ns

#define F(X) int _##X
F(i); // NON_COMPLIANT - user macro

#define FD_SET(X)                                                              \
  int _##X // NON_COMPLIANT - redefinition of standard library macro
FD_SET(j); // COMPLIANT - standard library macro

void f() {
  std::string x = __func__; // COMPLIANT
}

void g(int (*l)(int)) {}

void test_lambda(const int y) {
  // Lambda generates a static function called `_FUN` when the lambda is
  // converted to a function pointer
  g([](int x) { return x; }); // COMPLIANT - compiler generated
}