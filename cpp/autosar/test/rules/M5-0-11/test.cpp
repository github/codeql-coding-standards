typedef char m_char;

char a1 = 'a';
char a2 = 2; // NON_COMPLIANT
m_char a3 = 'a';
m_char a4 = 3; // NON_COMPLIANT

unsigned char a5 = 'a';
unsigned char a6 = 10; // COMPLIANT

void f1() {
  long l = 100;
  char a1 = 'a';
  char a2 = 2; // NON_COMPLIANT
  m_char a3 = 'a';
  m_char a4 = 3; // NON_COMPLIANT

  unsigned char a5 = 'a';
  unsigned char a6 = 10; // COMPLIANT

  signed char a7 = 10; // COMPLIANT - because signedness is explicit

  a1 = 10; // NON_COMPLIANT

  a1 = 10L; // NON_COMPLIANT

  a1 = l; // NON_COMPLIANT

  a5 = l; // COMPLIANT - however, mismatched sizes.
}