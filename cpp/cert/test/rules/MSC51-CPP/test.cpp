#include <ctime>
#include <random>

constexpr unsigned int seed = 100u;

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
  std::time_t t;
  std::default_random_engine e13{
      static_cast<unsigned int>(std::time(&t))}; // NON_COMPLIANT
  std::default_random_engine e14{2u};            // NON_COMPLIANT
  std::default_random_engine e15{seed};          // NON_COMPLIANT
}

class DefaultInitializedRandomNumberGeneratorField {
private:
  std::default_random_engine engine; // NON_COMPLIANT - intialized by the
                                     // implicit default constructor
};

class DefaultInitializedRandomNumberGeneratorField2 {
public:
  DefaultInitializedRandomNumberGeneratorField2()
      : engine2(seed) {} // NON_COMPLIANT - engine1 and engine2

private:
  std::default_random_engine engine;
  std::default_random_engine engine2;
};