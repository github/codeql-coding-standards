#include <vector>

wchar_t g;   // NON_COMPLIANT
char g2;     // COMPLIANT
char16_t g3; // COMPLIANT

template <typename T> T f2(T d2) { return d2; }

void f() {
  wchar_t l;                            // NON_COMPLIANT
  char l2;                              // COMPLIANT
  char16_t l3;                          // COMPLIANT
  auto l4 = static_cast<wchar_t>(l);    // NON_COMPLIANT
  std::vector<wchar_t> l5;              // NON_COMPLIANT
  std::vector<std::vector<wchar_t>> l6; // NON_COMPLIANT
  std::vector<std::vector<char>> l7;    // COMPLIANT

  for (wchar_t i; i < 2; i++) { // NON_COMPLIANT
  }

  l = f2(l);   // COMPLIANT
  l2 = f2(l2); // COMPLIANT
}

wchar_t f3(wchar_t d3) { return d3; } // NON_COMPLIANT

char f4(char d4) { return d4; } // COMPLIANT