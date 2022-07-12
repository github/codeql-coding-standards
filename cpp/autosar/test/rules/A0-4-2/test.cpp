#include <vector>

long double g; // NON_COMPLIANT
long g2;       // COMPLIANT

template <typename T> T f2(T d2) { return d2; }

void f() {
  long double l;                            // NON_COMPLIANT
  long l2;                                  // COMPLIANT
  double l3;                                // COMPLIANT
  auto l4 = static_cast<long double>(l);    // NON_COMPLIANT
  std::vector<long double> l5;              // NON_COMPLIANT
  std::vector<std::vector<long double>> l6; // NON_COMPLIANT
  std::vector<std::vector<long>> l7;        // COMPLIANT

  for (long double i; i < 2; i++) { // NON_COMPLIANT
  }

  l = f2(l);   // COMPLIANT
  l2 = f2(l2); // COMPLIANT
}

long double f3(long double d3) { return d3; } // NON_COMPLIANT

double f4(double d4) { return d4; } // COMPLIANT