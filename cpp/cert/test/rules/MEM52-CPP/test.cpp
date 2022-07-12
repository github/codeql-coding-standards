#include <new>
#include <stddef.h>

struct StructA {
  char *data;
};

void use(StructA *a);

bool test_local_simple(std::size_t size) {
  StructA *a1 = new (std::nothrow) StructA{}; // COMPLIANT
  if (!a1) {
    return false;
  }

  StructA *a2 = new (std::nothrow) StructA{}; // COMPLIANT
  if (a2) {

  } else {
    return false;
  }

  StructA *a3 =
      new (std::nothrow) StructA{}; // NON_COMPLIANT - used without a check
  a3->data = new char[size];        // not a nothrow, so not checked
}

int test_equality_conditional(StructA *a, std::size_t size) {
  a->data = new (std::nothrow) char[size]; // COMPLIANT - checked below

  return (a->data == nullptr) ? -1 : 0;
}

StructA *allocate_without_check() {
  StructA *a1 = new (std::nothrow) StructA{};
  return a1;
}

bool test_non_local() {
  StructA *a1 = allocate_without_check(); // NON_COMPLIANT - not checked
  use(a1);

  StructA *a2 = allocate_without_check(); // COMPLIANT
  if (!a2) {
    return false;
  }
  use(a2);

  return true;
}