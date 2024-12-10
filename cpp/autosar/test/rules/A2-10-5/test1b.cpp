namespace n1 {
static int g1 = 1; // NON_COMPLIANT
}

namespace n2 {
static int g3 = 0; // NON_COMPLIANT
}

static void f1() {} // NON_COMPLIANT

template <class T> static constexpr T number_two = T(1); // NON_COMPLIANT

int test5() { return number_two<int>; }

long test6() { return number_two<long>; }