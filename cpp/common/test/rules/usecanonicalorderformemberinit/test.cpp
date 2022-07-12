
class Base1 {};
class Base2 {};
class Base3 {};

class DirectDerived : public Base1, public Base2, public Base3 {
  DirectDerived() : Base2(), Base1(), Base3() {}       // NON_COMPLIANT
  DirectDerived(long l) : Base3(), Base1(), Base2() {} // NON_COMPLIANT
  DirectDerived(int i) : Base1(), Base2(), Base3() {}  // COMPLIANT
};

class MemberOrder {
public:
  int i1;
  union {
    int u1;
    union {
      long l1;
      double d1;
    };
  };
  int i2;

  MemberOrder() : i1(), u1(), i2() {}                        // COMPLIANT
  MemberOrder(int) : i1(), l1(), i2() {}                     // COMPLIANT
  MemberOrder(int, int) : i1(), d1(), i2() {}                // COMPLIANT
  MemberOrder(int, int, int) : i2(), u1(), i1() {}           // NON_COMPLIANT
  MemberOrder(int, int, int, int) : i2(), l1(), i1() {}      // NON_COMPLIANT
  MemberOrder(int, int, int, int, int) : i2(), d1(), i1() {} // NON_COMPLIANT
};

class VirtualBaseClass1 {};
class VirtualBaseClass2 {};
class VirtualBaseClass3 {};

class Derived1 : public virtual VirtualBaseClass1 {};
class Derived2 : public virtual VirtualBaseClass2,
                 public virtual VirtualBaseClass1 {};
class Derived3 : public virtual VirtualBaseClass3,
                 public Derived1,
                 public Derived2 {
  Derived3()
      : VirtualBaseClass3(), VirtualBaseClass1(), // COMPLIANT
        VirtualBaseClass2(),                      // COMPLIANT
        Derived1(), Derived2() {}                 // COMPLIANT
  Derived3(int)
      : VirtualBaseClass3(), VirtualBaseClass2(), // COMPLIANT
        VirtualBaseClass1(),                      // NON_COMPLIANT
        Derived1(), Derived2() {}                 // COMPLIANT
  Derived3(int, int)
      : Derived1(), VirtualBaseClass3(), VirtualBaseClass1(), // COMPLIANT
        Derived2(),                                           // COMPLIANT
        VirtualBaseClass2() {}                                // NON_COMPLIANT
};

class MixedBase {};
class MixedVirtualBase {};

class Mixed : public MixedBase, public virtual MixedVirtualBase {
public:
  int m_i;
  Mixed() : MixedVirtualBase(), MixedBase(), m_i() {}         // COMPLIANT
  Mixed(int) : MixedBase(), MixedVirtualBase(), m_i() {}      // NON_COMPLIANT
  Mixed(int, int) : m_i(), MixedBase(), MixedVirtualBase() {} // NON_COMPLIANT
};