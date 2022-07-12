void test() {
  int l1 = 0;
  [&l1] { // NON_COMPLIANT
    l1 += 1;
  };

  [&l1]() { // COMPLIANT
    l1 += 1;
  };

  // clang-format off
  [&l1]{ // NON_COMPLIANT
    l1 += 1;
  };
  [&l1]   { // NON_COMPLIANT
    l1 += 1;
  };

  [&l1](){ // COMPLIANT
    l1 += 1;
  };

  [&l1] (){ // COMPLIANT
    l1 += 1;
  };

  [&l1] ()  { // COMPLIANT
    l1 += 1;
  };
  // clang-format on
}