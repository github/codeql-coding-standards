#include <iostream>

class TestBool {
public:
  TestBool(bool value) : m1(value) {}
  bool getValue() const { return m1; }

private:
  bool m1;
};

// Non-compliant overloads
bool operator&&(const TestBool &l1, bool l2) { // NON_COMPLIANT
  return l1.getValue() && l2;
}

bool operator||(const TestBool &l1, bool l2) { // NON_COMPLIANT
  return l1.getValue() || l2;
}

TestBool operator&&(const TestBool &l1, const TestBool &l2) { // NON_COMPLIANT
  return TestBool(l1.getValue() && l2.getValue());
}

TestBool operator||(const TestBool &l1, const TestBool &l2) { // NON_COMPLIANT
  return TestBool(l1.getValue() || l2.getValue());
}