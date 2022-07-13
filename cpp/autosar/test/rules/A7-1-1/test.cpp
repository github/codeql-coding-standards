#include <iostream>
#include <string>

void f1(int *p) { // COMPLIANT
  *p += 2;
}
void f2(int *p) { // NON_COMPLIANT
  int l4 = 1;     // NON_COMPLIANT
  int *p1 = p;    // NON_COMPLIANT
}

void initl6(char *l) { l = {0}; }

void f() {
  const int l = 1;      // COMPLIANT
  constexpr int l1 = 1; // COMPLIANT
  int l2 = 1;           // NON_COMPLIANT

  int l3 = 1; // COMPLIANT
  f1(&l3);

  int l4 = 1; // COMPLIANT
  f2(&l4);

  const int l5[] = {1}; // COMPLIANT

  char l6[4]; // COMPLIANT
  initl6(l6);

  int l7[] = {1}; // NON_COMPLIANT
}

class A7_1_1a final {
public:
  struct A {
    std::string m;
  };
  void Set(const A &a) { // COMPLIANT
    m_ = a.m;
  }
  void Call() {
    [this]() { std::cout << m_ << '\n'; }(); // COMPLIANT ignore lambdas
  }

private:
  std::string m_;
};
