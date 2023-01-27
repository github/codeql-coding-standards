int a1;  // COMPLIANT
int a2;  // COMPLIANT
long a3; // NON_COMPLIANT
long a4; // NON_COMPLIANT
int a5;  // NON_COMPLIANT
long a6; // NON_COMPLIANT
int a7;  // NON_COMPLIANT

int a8;        // COMPLIANT
extern int a8; // COMPLIANT

int a9[100];  // COMPLIANT
int a10[100]; // NON_COMPLIANT
int a11[100]; // NON_COMPLIANT - different sizes
int a12;      // COMPLIANT

int *const a13; // NON_COMPLIANT
