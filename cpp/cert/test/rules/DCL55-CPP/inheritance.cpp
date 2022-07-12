#include <stddef.h>
#include <string>

unsigned long copy_to_user(void *to, const void *from, unsigned long n);

struct intBase {
  int i;
};

struct intDerived : public intBase {
  int j;
};

struct ptrDerived : public intBase {
  void *voidptr;
};

void forget_base() {
  intDerived s;
  s.j = 1;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT - `i` uninitialized
}

void remember_base() {
  intDerived s;
  s.j = 1;
  s.i = 1;
  copy_to_user(0, &s, sizeof s); // COMPLIANT - both initialized
}

void forget_padding() {
  ptrDerived s;
  s.voidptr = 0;
  s.i = 1;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT - there is most
                                 // likely padding after `i`
}