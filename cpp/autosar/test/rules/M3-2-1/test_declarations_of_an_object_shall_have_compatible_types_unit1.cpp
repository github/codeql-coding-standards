int a1;  // COMPLIANT
int a2;  // COMPLIANT
long a3; // COMPLIANT
long a4; // NON_COMPLIANT
int a5;  // NON_COMPLIANT
long a6; // NON_COMPLIANT
int a7;  // NON_COMPLIANT

int a8;        // COMPLIANT
extern int a8; // COMPLIANT

namespace A {
int a1; // COMPLIANT
int a2; // NON_COMPLIANT
} // namespace A

int a9[100];  // COMPLIANT
int a10[100]; // COMPLIANT
int a11[100]; // NON_COMPLIANT - different sizes
