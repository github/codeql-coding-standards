
#include <array>
#include <string_view>

int g[100]; // NON_COMPLIANT

class C {
public:
  static constexpr int a[1]{0}; // NON_COMPLIANT
  int a1[1];                    // NON_COMPLIANT
};

struct S {
  int a1[1]; // NON_COMPLIANT
};

void test_c_arrays() {

  int x[100];                 // NON_COMPLIANT
  constexpr int a[]{0, 1, 2}; // NON_COMPLIANT
  const size_t s{1};
  char x1[s];             // NON_COMPLIANT
  std::array<char, s> x2; // COMPLIANT

  __func__; // COMPLIANT
}

char g1[] = "abc";       // NON_COMPLIANT
const char g2[] = "abc"; // COMPLIANT

using namespace std::literals;
const auto g3 = "abc"sv; // COMPLIANT

void param_test(int p[1], int (&p1)[1], int (*p2)[1],
                int *p3) { // NON_COMPLIANT -- p, rest are compliant
}