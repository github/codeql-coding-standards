
int a1 = 0L;  // COMPLIANT
int a2 = 0l;  // NON_COMPLIANT
int a3 = 0ll; // NON_COMPLIANT
int a4 = 0LL; // COMPLIANT
int a5 = 0uL; // COMPLIANT
int a6 = 0ul; // NON_COMPLIANT
int a7 = 0lu; // NON_COMPLIANT
int a8 = 0Lu; // COMPLIANT
int a9 = 0LU; // COMPLIANT

long b1 = 0L;  // COMPLIANT
long b2 = 0l;  // NON_COMPLIANT
long b3 = 0ll; // NON_COMPLIANT
long b4 = 0LL; // COMPLIANT
long b5 = 0uL; // COMPLIANT
long b6 = 0ul; // NON_COMPLIANT
long b7 = 0lu; // NON_COMPLIANT
long b8 = 0Lu; // COMPLIANT
long b9 = 0LU; // COMPLIANT

int c1 = 0x01L;  // COMPLIANT
int c2 = 0x01l;  // NON_COMPLIANT
int c3 = 0x01ll; // NON_COMPLIANT
int c4 = 0x01LL; // COMPLIANT
int c5 = 0x01uL; // COMPLIANT
int c6 = 0x01ul; // NON_COMPLIANT
int c7 = 0x01lu; // NON_COMPLIANT
int c8 = 0x01Lu; // COMPLIANT
int c9 = 0x01LU; // COMPLIANT

long d1 = 001L;  // COMPLIANT
long d2 = 001l;  // NON_COMPLIANT
long d3 = 001ll; // NON_COMPLIANT
long d4 = 001LL; // COMPLIANT
long d5 = 001uL; // COMPLIANT
long d6 = 001ul; // NON_COMPLIANT
long d7 = 001lu; // NON_COMPLIANT
long d8 = 001Lu; // COMPLIANT
long d9 = 001LU; // COMPLIANT

char *e1 = "";
char *e2 = "ul";
char *e3 = "UL";
