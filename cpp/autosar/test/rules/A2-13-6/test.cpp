const char *l1 = "\u0041"; // COMPLIANT
int l2_\u00a8;             // NON_COMPLIANT
void f1_\u00a8();          // NON_COMPLIANT

namespace ns_\u00a8 {} // namespace ns_\u00a8
class class_\u00a8 {   // NON_COMPLIANT
  class_\u00a8() {}    // NON_COMPLIANT

  void member1_\u00a8() {}      // NON_COMPLIANT
  void member2(int p_\u00a8) {} // NON_COMPLIANT
};