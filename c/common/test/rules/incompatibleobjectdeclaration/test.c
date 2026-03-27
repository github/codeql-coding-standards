short i;                // NON_COMPLIANT
int a[] = {1, 2, 3, 4}; // NON_COMPLIANT

long f(int a) { // NON_COMPLIANT
  return a * 2;
}

void f1(long a); // NON_COMPLIANT
void f2() {}     // NON_COMPLIANT
int f3();        // COMPLIANT