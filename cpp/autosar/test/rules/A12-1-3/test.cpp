class ClassA {
public:
  ClassA() : m_i1(1), m_i2(1), m_i3(0), m_i4(0) {}
  ClassA(int i1) : m_i1(i1), m_i2(2), m_i3(0), m_i4(0) {}
  ClassA(int i1, int i2) : m_i1(i1 + i2), m_i2(3), m_i3(0) {}

private:
  int m_i1; // COMPLIANT - not always constant
  int m_i2; // COMPLIANT - always constant, but different
  int m_i3; // NON_COMPLIANT - always the same value
  int m_i4; // COMPLIANT - sometimes compiler generated initializer
};

class ClassB {
private:
  int m_i1; // COMPLIANT - only initialized in implicit constructors
};