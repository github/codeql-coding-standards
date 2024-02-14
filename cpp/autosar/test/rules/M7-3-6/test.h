#ifndef FRIENDTEST_H_
#define FRIENDTEST_H_

using namespace ::std; // NON-COMPLIANT

namespace my_namespace {
int MY_CONST = 0;
};

void f() {

  using my_namespace::MY_CONST; // COMPLIANT - function scope

  int x = MY_CONST;
}

void test_fn_reported_in_400() {
  using namespace std; // NON_COMPLIANT - only using declarations are exempted
                       // in function scope.
}
#endif