// semmle-extractor-options:--clang -std=c99 -nostdinc
// -Wno-implicit-function-declaration
void declared(void);

void c99_calls(void) {
  declared();   // COMPLIANT
  undeclared(); // NON_COMPLIANT
}