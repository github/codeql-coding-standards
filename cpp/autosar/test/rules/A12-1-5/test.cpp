class ClassA {
public:
  ClassA(int i1, int i2)
      : m_i1(i1 + 8),      // NON_COMPLIANT
        m_i2(i2),          // COMPLIANT
        m_i3(new int[10]), // NON_COMPLIANT
        m_i4(new int[10])  // COMPLIANT
  {}
  ClassA(int i1)
      : m_i1(i1 + 8),      // not reported - we only report the first instance
        m_i2(0),           // COMPLIANT
        m_i3(new int[10]), // not reported - we only report the first instance
        m_i4(new int[5])   // COMPLIANT
  {}

private:
  int m_i1;
  int m_i2;
  int *m_i3;
  int *m_i4;
};

class ClassB {
public:
  ClassB(int i1, int i2)
      : m_i1(i1 + 8), // COMPLIANT
        m_i2(i2)      // COMPLIANT
  {}
  ClassB(int i1)
      : ClassB(i1, 0) // COMPLIANT
  {}

private:
  int m_i1;
  int m_i2;
};