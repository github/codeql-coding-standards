int main() {
  int n = 2;
  // NON_COMPLIANT - extended inline assembly
  asm("leal (%0,%0,4),%0" : "=r"(n) : "0"(n));

  // NON_COMPLIANT - standard inline assembly
  asm("movq $60, %rax\n\t" // the exit syscall number on Linux
      "movq $2,  %rdi\n\t" // this program returns 2
      "syscall");
}