namespace n1 {
static int g1 = 1; // NON_COMPLIANT[FALSE_NEGATIVE], considered the same as
                   // n1::g1 in test1a.cpp.
}

namespace n2 {
static int g3 = 0; // NON_COMPLIANT
}

static void f1() {} // NON_COMPLIANT

template <class T> constexpr T number_two = T(1); // NON_COMPLIANT

int test3() { return number_two<int>; }

long test4() { return number_two<long>; }