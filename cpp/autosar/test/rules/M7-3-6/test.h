#ifndef FRIENDTEST_H_
#define FRIENDTEST_H_

using namespace ::std; // NON-COMPLIANT

namespace my_namespace {
int MY_CONST = 0;
};

int f() {

  using my_namespace::MY_CONST; // COMPLIANT - function scope

  int x = MY_CONST;
}

#endif