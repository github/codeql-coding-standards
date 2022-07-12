void f1(int32_t p[10]);
void f2(int32_t *p);
void f3(int32_t (&p)[10]);
void b() {
  int32_t a[10];
  f1(a); // Non-compliant - Dimension "10" lost due to array to
         // pointer conversion.
  f2(a); // Non-compliant - Dimension "10" lost due to array to
         // pointer conversion.
  f3(a); // Compliant - Dimension preserved.
}
