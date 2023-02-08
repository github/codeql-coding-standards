// semmle-extractor-options:--clang -std=c11 -nostdinc
// -I../../../../common/test/includes/standard-library
double f1(double x); // COMPLIANT
f2(double x);        // NON_COMPLIANT

void f() {
  double l = 1;
  double l1 = f1(l);

  double l2 = f2(l);

  double l3 = f3(l); // NON_COMPLIANT
}