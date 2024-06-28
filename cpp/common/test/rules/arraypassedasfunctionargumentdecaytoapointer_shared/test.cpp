void f1(int p[20]);
void f2(int *p);
void f3(int (&p)[20]);

void f() {
  int foo[20]; // Dimension needs to match with parameter p of f3

  f1(foo); // NON_COMPLIANT - Dimension "20" lost due to array to pointer
           // conversion
  f2(foo); // NON_COMPLIANT - Dimension "20" lost due to array to pointer
           // conversion
  f3(foo); // COMPLIANT
}