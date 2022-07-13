void Delay(void) {
  asm("NOP"); // Compliant
}
void fn(void) {
  DoSomething();
  Delay(); // Assembler is encapsulated
  DoSomething();
  asm("NOP"); // Non-compliant
  DoSomething();
}
