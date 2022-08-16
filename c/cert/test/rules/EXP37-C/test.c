#include <complex.h>
#include <fcntl.h>
#include <math.h>
#include <stddef.h>

const int G_FLAG_TEST = O_RDONLY;
const int G_FLAG_CREATE_TEST = O_RDWR | O_APPEND | O_CREAT;

void test_open_nested(const char *path, int flags) {
  open(path, flags);    // NON_COMPLIANT[FALSE_NEGATIVE]
  open(path, flags, 0); // COMPLIANT
}

void test_open(const char *path) {
  int flags;

  open(path, O_APPEND | O_RDWR);    // COMPLIANT
  open(path, O_APPEND | O_RDWR, 0); // NON_COMPLIANT
  open(path, O_CREAT);              // NON_COMPLIANT

  flags = O_APPEND | O_RDWR;
  open(path, flags);    // COMPLIANT
  open(path, flags, 0); // NON_COMPLIANT

  flags |= O_CREAT;
  open(path, flags);    // NON_COMPLIANT
  open(path, flags, 0); // COMPLIANT
  test_open_nested(path, flags);

  flags &= ~O_CREAT;
  open(path, flags);    // COMPLIANT
  open(path, flags, 0); // NON_COMPLIANT[FALSE_NEGATIVE]

  open(path, G_FLAG_TEST, 0);     // NON_COMPLIANT
  open(path, G_FLAG_CREATE_TEST); // NON_COMPLIANT
}

typedef void (*fp1)(void);
typedef void (*fp2)(int p1);
extern void f1(void);
extern void f2(int p1);

struct f_ptr_table {
  fp1 f1;
  fp2 f2;
};

void test_incompatible_function_pointer_nested(struct f_ptr_table *fns) {
  fns->f1();
  fns->f2(0);
}

void test_incompatible_function_pointer(void) {
  fp1 v1 = NULL;
  fp1 v1_called = f2; // COMPLIANT
  fp2 v2 = NULL;
  fp2 v2_called = NULL;
  fp2 v3_called = NULL;

  v1 = (fp1)(void *)f2;        // COMPLIANT
  v1_called = (fp1)(void *)f2; // NON_COMPLIANT
  v1_called();

  v2 = f2;        // COMPLIANT
  v2_called = f2; // COMPLIANT
  v2_called(0);

  v3_called = v2; // COMPLIANT
  v3_called(0);
  ((fp1)v3_called)(); // NON_COMPLIANT

  struct f_ptr_table fns;
  fns.f1 = v2; // NON_COMPLIANT
  fns.f2 = v2; // COMPLIANT
  test_incompatible_function_pointer_nested(&fns);
}

void test_complex_types(void) {
  double r = 1.0;
  double complex c = r * I;
  double complex result;

  result = atan2(c, r);        // NON_COMPLIANT
  result = atan2(creal(c), r); // COMPLIANT
  result = casin(c);           // COMPLIANT
}

void test_func1();
void test_func2(int);
void test_func3(int p1, ...);

void test_incompatible_arguments(int p1, short p2) {
  test_func1(p1);                   // NON_COMPLIANT
  test_func1(p2);                   // NON_COMPLIANT
  ((int (*)(short))test_func1)(p2); // COMPLIANT
  test_func2(0);                    // COMPLIANT
  test_func3(0);                    // NON_COMPLIANT[FALSE_NEGATIVE]
  test_func3(0, 1);                 // NON_COMPLIANT[FALSE_NEGATIVE]
}