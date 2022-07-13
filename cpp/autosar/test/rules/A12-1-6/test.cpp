class ClassA {
public:
  ClassA(const int p1) : m_1(p1) {} // const should be ignored

private:
  int m_1;
};

class ClassB : public ClassA { // COMPLIANT
public:
  using ClassA::ClassA;
};

class ClassC : public ClassA { // NON_COMPLIANT
public:
  ClassC(int p1) : ClassA(p1) {}
  // Additional constructors
  ClassC(int p1, int p2) : ClassA(p1 + p2) {}
};

int global;

class ClassD : public ClassA { // COMPLIANT - does not pointlessly reimplement
public:
  ClassD(int p1) : ClassA(p1) { global++; }
};

class PrivateDerivedClass : public ClassA { // COMPLIANT - changes visibility
private:
  PrivateDerivedClass(int p1) : ClassA(p1) {}
};

class ManyDefaultsBaseClass {
public:
  ManyDefaultsBaseClass(int p1, int p2 = 0, int p3 = 0, int p4 = 0, int p5 = 0)
      : m_1(p1), m_2(p2), m_3(p3), m_4(p4), m_5(p5) {}

private:
  int m_1;
  int m_2;
  int m_3;
  int m_4;
  int m_5;
};

// This class provides a constructor for each of the possible
// calls to the base class constructor
class AllOverridesDerivedClass : public ManyDefaultsBaseClass { // NON_COMPLIANT
public:
  AllOverridesDerivedClass(int p1, int p2, int p3, int p4, int p5)
      : ManyDefaultsBaseClass(p1, p2, p3, p4, p5) {}
  AllOverridesDerivedClass(int p1, int p2, int p3, int p4)
      : ManyDefaultsBaseClass(p1, p2, p3, p4) {}
  AllOverridesDerivedClass(int p1, int p2, int p3)
      : ManyDefaultsBaseClass(p1, p2, p3) {}
  AllOverridesDerivedClass(int p1, int p2) : ManyDefaultsBaseClass(p1, p2) {}
  AllOverridesDerivedClass(int p1) : ManyDefaultsBaseClass(p1) {}
};

// All
class MissingOverridesDerivedClass : public ManyDefaultsBaseClass { // COMPLIANT
public:
  MissingOverridesDerivedClass(int p1, int p2, int p3, int p4, int p5)
      : ManyDefaultsBaseClass(p1, p2, p3, p4, p5) {}
  MissingOverridesDerivedClass(int p1, int p2, int p3, int p4)
      : ManyDefaultsBaseClass(p1, p2, p3, p4) {}
  // Deliberately excluded the following case:
  // MissingOverridesDerivedClass(int p1, int p2, int p3)
  //     : ManyDefaultsBaseClass(p1, p2, p3) {}
  MissingOverridesDerivedClass(int p1, int p2)
      : ManyDefaultsBaseClass(p1, p2) {}
  MissingOverridesDerivedClass(int p1) : ManyDefaultsBaseClass(p1) {}
};

class MismatchParameterTypeBase {
public:
  MismatchParameterTypeBase(int p1) : m_1(p1) {}

private:
  int m_1;
};

class MismatchParameterTypeDerived
    : public MismatchParameterTypeBase { // COMPLIANT
public:
  // Different type from base
  MismatchParameterTypeDerived(long p1) : MismatchParameterTypeBase(p1) {}
};

class MismatchExplicitBase {
public:
  explicit MismatchExplicitBase(int p1) : m_1(p1) {}

private:
  int m_1;
};

class MismatchExplicitDerived : public MismatchExplicitBase { // COMPLIANT
public:
  // Base is explicit, but this is not
  MismatchExplicitDerived(int p1) : MismatchExplicitBase(p1) {}
};

class MismatchNotExplicitBase {
public:
  MismatchNotExplicitBase(int p1) : m_1(p1) {}

private:
  int m_1;
};

class MismatchNotExplicitDerived : public MismatchNotExplicitBase { // COMPLIANT
public:
  // Base is not explicit, but this is
  explicit MismatchNotExplicitDerived(int p1) : MismatchNotExplicitBase(p1) {}
};

class MismatchConstExprBase {
public:
  constexpr MismatchConstExprBase(int p1) : m_1(p1) {}

private:
  int m_1;
};

class MismatchConstExprDerived : public MismatchConstExprBase { // COMPLIANT
public:
  // Base is constexpr, but this is not
  MismatchConstExprDerived(int p1) : MismatchConstExprBase(p1) {}
};

class SwappedBase {
public:
  SwappedBase(int p1, int p2) : m_1(p1), m_2(p2) {}

private:
  int m_1;
  int m_2;
};

class SwappedDerived : public SwappedBase { // COMPLIANT - parameters swapped
public:
  SwappedDerived(int p1, int p2) : SwappedBase(p2, p1) {}
};