void f1() {
  auto l1 = [](int p1) -> int { return p1 + 1; }; // COMPLIANT
  auto l2 = [](int p1) { return p1 + 1; };        // NON_COMPLIANT
}