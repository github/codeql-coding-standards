#include <initializer_list>

class ClassA {
public:
  ClassA();
  ClassA(int i);
};

class ClassB {
public:
  ClassB(int i, int j);
  ClassB(std::initializer_list<int> list);
};

void test() {
  int i1{1};                 // COMPLIANT
  int i2 = 1;                // NON_COMPLIANT
  int i3 = 1.1;              // NON_COMPLIANT
  int i4 = {1};              // NON_COMPLIANT
  int i5;                    // COMPLIANT
  ClassA a1;                 // COMPLIANT
  ClassA a2{};               // COMPLIANT
  ClassA a3{1};              // COMPLIANT
  ClassA a4 = 1;             // NON_COMPLIANT
  ClassA a5 = {};            // NON_COMPLIANT
  ClassA a6 = {1};           // NON_COMPLIANT
  ClassA *a7 = nullptr;      // NON_COMPLIANT
  ClassA *a8{nullptr};       // COMPLIANT
  ClassA *a9 = new ClassA(); // NON_COMPLIANT
  ClassA *a10{new ClassA()}; // COMPLIANT
  ClassA a11(1); // NON_COMPLIANT[FALSE_NEGATIVE] - cannot distingush between ()
                 // and {} based on locations alone
  ClassB b1(1, 2); // COMPLIANT - bracket initialization required, because the
                   // initializer_list constructor will be incorrectly preferred
                   // when using {} initialization
  [i1](int a) { // Ensure initializers associated with lambdas are not flagged
    a;
    i1;
  };
}

void f() {
  auto x = 1; // COMPLIANT ignore auto vars
}