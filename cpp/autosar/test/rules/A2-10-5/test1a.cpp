namespace n1 {
static int g1 = 0; // NON_COMPLIANT
}

static int g2;      // COMPLIANT
static int g3 = 1;  // NON_COMPLIANT
static void f1(){}; // NON_COMPLIANT

// Variable template has multiple declarations: one for the uninstantiated
// template and one for each instantiation
template <class T> constexpr T number_one = T(1); // COMPLIANT

int test() { return number_one<int>; }

long test2() { return number_one<long>; }

template <class T> constexpr T number_two = T(1); // NON_COMPLIANT

int test3() { return number_two<int>; }

long test4() { return number_two<long>; }
