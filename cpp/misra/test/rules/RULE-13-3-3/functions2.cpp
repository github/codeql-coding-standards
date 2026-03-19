void f1(int a); // COMPLIANT -- same name
void f2(int);   // COMPLIANT -- unnamed is fine

void f3(int a,
        int b); // COMPLIANT -- diff number but for those that exist, same
void f4(int a, int b); // NON_COMPLIANT -- diff name
void f5(int a, int b); // NON_COMPLIANT -- swapped names

typedef int wi;
typedef int hi;
typedef long a;

extern a f6(wi w, hi h); // NON_COMPLIANT

extern void f7(int a, int b); // NON_COMPLIANT

extern void f8(int); // COMPLIANT