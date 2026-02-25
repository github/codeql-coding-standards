#include <cstdint>

// Base class for testing virtual inheritance
struct Base {
  virtual std::int32_t getValue() { return 1; }
  std::int32_t m1;
};

// Another base class
struct AnotherBase {
  std::int32_t m2;
};

// Test cases for virtual inheritance (non-compliant)
struct VirtualDerived1 : public virtual Base { // NON_COMPLIANT
  std::int32_t getDoubleValue() { return getValue() * 2; }
};

struct VirtualDerived2 : public virtual Base { // NON_COMPLIANT
  std::int32_t getValue() override { return 3; }
};

struct VirtualMultiple : public virtual Base,
                         public virtual AnotherBase { // NON_COMPLIANT
  std::int32_t m3;
};

// Test cases for private virtual inheritance (non-compliant)
struct PrivateVirtualDerived : private virtual Base { // NON_COMPLIANT
  std::int32_t m4;
};

struct ProtectedVirtualDerived : protected virtual Base { // NON_COMPLIANT
  std::int32_t m5;
};

// Test cases for regular inheritance (compliant)
struct RegularDerived1 : public Base { // COMPLIANT
  std::int32_t getTripleValue() { return getValue() * 3; }
};

struct RegularDerived2 : public Base { // COMPLIANT
  std::int32_t getValue() override { return 4; }
};

struct RegularMultiple : public Base, public AnotherBase { // COMPLIANT
  std::int32_t m6;
};

struct PrivateRegularDerived : private Base { // COMPLIANT
  std::int32_t m7;
};

struct ProtectedRegularDerived : protected Base { // COMPLIANT
  std::int32_t m8;
};

// Diamond hierarchy with virtual inheritance (non-compliant)
struct DiamondLeft : public virtual Base { // NON_COMPLIANT
  std::int32_t leftMethod() { return getValue() + 10; }
};

struct DiamondRight : public virtual Base { // NON_COMPLIANT
  std::int32_t getValue() override { return 5; }
};

struct DiamondBottom : public DiamondLeft, public DiamondRight { // COMPLIANT
  std::int32_t bottomMethod() {
    return leftMethod(); // Calls DiamondRight::getValue() due to dominance
  }
};

void test_edge_cases() {
  // Multiple levels of virtual inheritance
  struct Level1 : public virtual Base { // NON_COMPLIANT
    std::int32_t m9;
  };

  struct Level2 : public virtual Level1 { // NON_COMPLIANT
    std::int32_t m10;
  };
}