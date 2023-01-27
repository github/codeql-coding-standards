extern int a1; // COMPLIANT

#define EE extern int a2
EE; // COMPLIANT

typedef long LL;
typedef int LI;

extern LL a3; // COMPLIANT

extern int a4; // NON_COMPLIANT

extern long a5; // NON_COMPLIANT

#define EE1 extern int a6

EE1; // NON_COMPLIANT

extern LL a7; // NON_COMPLIANT

namespace A {
extern int a1;  // COMPLIANT
extern long a2; // NON_COMPLIANT
} // namespace A

extern int a9[100];  // COMPLIANT
LI a10[100];         // COMPLIANT
extern int a11[101]; // NON_COMPLIANT - different sizes

template <class T> class ClassB {
private:
  T mA;   // Should be ignored, as not an object
  int mB; // Should be ignored, as not an object
};

void testb_1() { ClassB<int> b; }
void testb_2() { ClassB<long> b; }