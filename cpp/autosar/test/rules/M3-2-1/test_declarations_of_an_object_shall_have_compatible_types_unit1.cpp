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

// Variable templates can cause false positives
template <class T> constexpr T number_one = T(1); // COMPLIANT

int test() { return number_one<int>; }

long test2() { return number_one<long>; }

template <class T> class ClassB {
private:
  T mA;      // Should be ignored, as not an object
  double mB; // Should be ignored, as not an object
};

void test3() { ClassB<int> b; }
void test4() { ClassB<long> b; }