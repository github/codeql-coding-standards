void foo();
void test_asm_f1() {
  asm("NOP"); // COMPLIANT
}

void test_asm_f2() {
  foo();
  test_asm_f1(); // COMPLIANT
  asm("NOP");    // NON_COMPLIANT
}

void test_asm_f3() {
  asm("NOP"); // COMPLIANT
  asm("NOP"); // COMPLIANT
  asm("NOP"); // COMPLIANT
}

void test_asm_f4() {
  foo();
  test_asm_f1(); // COMPLIANT
  foo();
}

void test_asm_f5() {
  asm("NOP"); // NON_COMPLIANT
  foo();
  asm("NOP"); // NON_COMPLIANT
  asm("NOP"); // NON_COMPLIANT
}
