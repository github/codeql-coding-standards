int g1, g2; // NON_COMPLIANT
int g3;     // COMPLIANT

namespace n1 {
int n_v1, n_v2; // NON_COMPLIANT
int n_v3;       // COMPLIANT
} // namespace n1

void f() {
  int l1, l2; // NON_COMPLIANT
  int l3;     // COMPLIANT
}

class ClassA {
  int m1, m2; // NON_COMPLIANT
  int m3;     // COMPLIANT
};

#include <vector>
void test_loop(std::vector<ClassA> v) {
  for (const auto b : v) { // COMPLIANT - DeclStmt is compiler generated
    b;
  }
}