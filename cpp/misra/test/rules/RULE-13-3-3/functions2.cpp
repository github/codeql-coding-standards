void f1(int a); // COMPLIANT -- same name
void f2(int);   // COMPLIANT -- unnamed is fine

void f3(int a,
        int b); // COMPLIANT -- diff number but for those that exist, same
void f4(int a, int b); // NON_COMPLIANT -- diff name
void f5(int a, int b); // NON_COMPLIANT -- swapped names

extern void f6(int a, int b); // NON_COMPLIANT

extern void f7(int); // COMPLIANT