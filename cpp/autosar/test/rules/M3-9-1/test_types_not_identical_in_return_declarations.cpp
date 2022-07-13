typedef long LL;

long f11(int a11, long b11); // NON_COMPLIANT - Is not a token for token match.
LL f11(int a11, long b11);   // NON_COMPLIANT - Is not a token for token match.

extern long f12(int a12); // NON_COMPLIANT - Is not a token for token match.
extern LL f12(int a12);   // NON_COMPLIANT - Is not a token for token match.

long f13(int a13);            // NON_COMPLIANT - Is not a token for token match.
LL f13(int a13) { return 0; } // NON_COMPLIANT - Is not a token for token match.

long f14(int a14, long b14);
long f14(int a14, long b14); // COMPLIANT - Is a token for token match.

extern long f15(int a15);
extern long f15(int a15); // COMPLIANT - Is a token for token match.

long f16(int a16);
long f16(int a16) { return 0; } // COMPLIANT - Is a token for token match.

class A2 {
public:
  long f1(int a1, int b1); // NON_COMPLIANT - Is not a token for token match.
};

LL A2::f1(int a1, int b1) { // NON_COMPLIANT - Is not a token for token match.
  return 0;
}
