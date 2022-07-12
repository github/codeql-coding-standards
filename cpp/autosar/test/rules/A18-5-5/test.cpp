#include <new>

void *malloc1(int b) __attribute__((malloc));

void *malloc1(int b) { // NON_COMPLIANT - recursion

  if (b == 0) {
    return nullptr;
  }

  return malloc1(b - 1);
}

void *malloc2(int b) __attribute__((no_caller_saved_registers, __malloc__));
void *malloc2(int b) { // NON_COMPLIANT - execution doesn't depend on b

  for (int i = 0; i < 10; i++) {
    return nullptr;
  }
  return nullptr;
}

int compare_to(int a, int b);
void *malloc3(int b) __attribute__((malloc));
void *malloc3(int b) { // NON_COMPLIANT - complex condition in loop condition,
                       // doesn't depend on b

  for (int i = 0; i < compare_to(i, 10); i++) {
    return nullptr;
  }
  return nullptr;
}

void *malloc4(int b) __attribute__((malloc));
void *malloc4(int b) { // NON_COMPLIANT - missing termination condition, doesn't
                       // depend on b

  for (int i = 0;; i++) {
    return nullptr;
  }
  return nullptr;
}

void h1() {} // NON_COMPLIANT - empty function
void h2() {  // NON_COMPLIANT - recursion
  if (true) {
    h2();
  }
}
void f1() {
  std::set_new_handler(h1);
  std::set_new_handler(h2);
}