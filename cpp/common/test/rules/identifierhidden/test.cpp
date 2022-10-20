int id1;

namespace {
int id1; // NON_COMPLIANT
}

namespace ns1 {
int id1; // COMPLIANT

namespace ns2 {
int id1; // COMPLIANT
}
} // namespace ns1

class C1 {
  int id1; // COMPLIANT
};

void f1() {
  int id1; // NON_COMPLIANT
}

void f2(int id1) {} // NON_COMPLIANT

void f3() {
  for (int id1; id1 < 1; id1++) { // NON_COMPLIANT
    for (int id1; id1 < 1; id1++) {
    } // NON_COMPLIANT
  }
}