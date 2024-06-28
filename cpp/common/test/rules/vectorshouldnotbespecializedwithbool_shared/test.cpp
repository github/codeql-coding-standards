#include <vector>

std::vector<bool> g;  // NON_COMPLIANT
std::vector<long> g1; // COMPLIANT

template <typename T> T f2(T d2) { return d2; }

template <class T> class vector {
public:
  vector() throw(); // COMPLIANT
};

class boolw {
  boolw() throw(); // COMPLIANT
};

void f() {
  std::vector<bool> l;                            // NON_COMPLIANT
  std::vector<long> l2;                           // COMPLIANT
  auto l3 = static_cast<std::vector<bool>>(l);    // NON_COMPLIANT
  vector<boolw> l4;                               // COMPLIANT
  std::vector<boolw> l5;                          // COMPLIANT
  std::vector<std::vector<bool>> l6;              // NON_COMPLIANT
  std::vector<std::vector<std::vector<bool>>> l7; // NON_COMPLIANT
  std::vector<std::vector<std::vector<int>>> l8;  // COMPLIANT

  for (std::vector<bool>::iterator it = l.begin(); it != l.end(); ++it) {
  } // want error at l declaration

  l = f2(l);   // COMPLIANT
  l2 = f2(l2); // COMPLIANT
}

std::vector<bool> f3(std::vector<bool> d3) { return d3; } // NON_COMPLIANT

std::vector<int> f4(std::vector<int> d4) { return d4; } // COMPLIANT