void Delay_a(void) {
  asm("NOP"); // Compliant
}
void Delay_b(void) {
#pragma asm
  "NOP" // Non-compliant
#pragma endasm
}