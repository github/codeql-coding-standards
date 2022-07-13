void f1() {
  auto l1 = []() {
    auto l1 = []() {}; // NON_COMPLIANT
    l1();
  };

  auto l2 = []() {};         // COMPLIANT
  auto l3 = [&]() { l2(); }; // COMPLIANT
}