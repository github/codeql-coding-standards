void test_asm_f1() {
  asm("NOP"); // COMPLIANT
}

void test_asm_f2() {
#pragma asm // NON_COMPLIANT
  "NOP";
#pragma endasm
}

void test_asm_f3() {
#pragma message "Foo!" // COMPLIANT
}
