int a1;
extern int a1; // COMPLIANT - Is a token for token match.

#define EE extern int a2
int a2;
EE; // COMPLIANT - Macro expands to be a token for token match.

typedef long LL;
long a3;      // NON_COMPLIANT - Although types are compatible, this is not a
              // token for token match.
extern LL a3; // NON_COMPLIANT - Although types are compatible, this is not a
              // token for token match.

class A1 {
public:
  int f1(int a1, int b1); // NON_COMPLIANT - b is not a token for token match.
  int f2(int a2, int b2) {
    return 0;
  } // COMPLIANT - Inline definition/declaration.
};

int A1::f1(int a,
           const int b) { // NON_COMPLIANT - b is not a token for token match.
  return 0;
}

int f1(int a1, int b1);
int f1(int a1, int b1) { return 0; } // COMPLIANT - Is a token for token match.

int f2(int a2, int b2); // NON_COMPLIANT - Is not a token for token match.
int f2(int a2,
       const int b2) { // NON_COMPLIANT - Is not a token for token match.
  return 0;
}

int f3(int a3, int b3) {
  return 0;
} // COMPLIANT - Inline definition/declaration

int f4(int a4, LL b4);    // NON_COMPLIANT - Not a token for token match.
int f4(int a4, long b4) { // NON_COMPLIANT - Not a token for token match.
  return 0;
}

int f5(int a5, long b5); // NON_COMPLIANT - Not a token for token match.
int f5(int a5, LL b5);   // NON_COMPLIANT - Not a token for token match.

extern LL a4;   // NON_COMPLIANT - Not a token for token match.
extern long a4; // NON_COMPLIANT - Not a token for token match.

extern long a5; // NON_COMPLIANT - Not a token for token match.
extern LL a5;   // NON_COMPLIANT - Not a token for token match.

int f6(int a6, long b6);
int f6(int a6, long b6); // COMPLIANT - Is a token for token match.

extern int f7(int a7, long b7);
extern int f7(int a7, long b7); // COMPLIANT - Is a token for token match.

int f8(int a8, long b8);
extern int f8(int a8, long b8);
extern int f8(int a8, long b8); // COMPLIANT - Is a token for token match.

extern int f9(int a9,
              long b9);       // NON_COMPLIANT - Is not a token for token match.
int f9(int a9, long b9);      // NON_COMPLIANT - Is not a token for token match.
extern int f9(int a9, LL b9); // NON_COMPLIANT - Is not a token for token match.

int f10(int a10, LL b10); // NON_COMPLIANT - Is not a token for token match.
extern int f10(int a10,
               long b10); // NON_COMPLIANT - Is not a token for token match.
extern int f10(int a10,
               LL b10); // NON_COMPLIANT - Is not a token for token match.
