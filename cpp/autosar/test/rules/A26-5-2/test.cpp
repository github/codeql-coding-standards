#include <random>

void test_misuse() {
  std::random_device rd;
  std::default_random_engine e1{rd()}; // COMPLIANT
  std::default_random_engine e2{};     // NON_COMPLIANT
  std::default_random_engine e3;       // NON_COMPLIANT
  std::minstd_rand0 e4;                // NON_COMPLIANT
  std::minstd_rand e5;                 // NON_COMPLIANT
  std::mt19937 e6;                     // NON_COMPLIANT
  std::mt19937_64 e7;                  // NON_COMPLIANT
  std::ranlux24_base e8;               // NON_COMPLIANT
  std::ranlux48_base e9;               // NON_COMPLIANT
  std::ranlux24 e10;                   // NON_COMPLIANT
  std::ranlux48 e11;                   // NON_COMPLIANT
  std::knuth_b e12;                    // NON_COMPLIANT
}

class DefaultInitializedRandomNumberGeneratorField {
private:
  std::default_random_engine engine; // NON_COMPLIANT - intialized by the
                                     // implicit default constructor
};

class DefaultInitializedRandomNumberGeneratorField2 {
public:
  DefaultInitializedRandomNumberGeneratorField2() {} // NON_COMPLIANT

private:
  std::default_random_engine engine;
};