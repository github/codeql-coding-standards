class Base {};
class Derived : public Base {
public:
  Derived() {}               // NON_COMPLIANT - does not call Base()
  Derived(int i) : Base() {} // COMPLIANT
  Derived(int i, int j);     // IGNORED - not defined, so we don't know
};

class Derived1 : public Base {
public:
  Derived1() = default; // COMPLIANT - `default` does not have explicit
                        //             initializers
};

class VirtualBase {};

class Derived2 : virtual public VirtualBase {};

class Derived3 : virtual public VirtualBase {};

class Derived4 : public Derived2, public Derived3 {
public:
  Derived4() {}   // NON_COMPLIANT - does not call Derived2(), Derived3() or
                  // VirtualBase()
  Derived4(int i) // NON_COMPLIANT - does not call VirtualBase()
      : Derived2(), Derived3() {}
  Derived4(int i, int j) // COMPLIANT - calls VirtualBase()
      : Derived2(), Derived3(), VirtualBase() {}
};

class NonTrivialBase {
public:
  NonTrivialBase() = default;
  NonTrivialBase(int i){};
  NonTrivialBase(int i, int j){};
};

class Derived5 : public NonTrivialBase {
public:
  Derived5() {} // NON_COMPLIANT - does not call NonTrivialBase()
  Derived5(int i) : NonTrivialBase(i) {}           // COMPLIANT
  Derived5(int i, int j) : NonTrivialBase(i, j) {} // COMPLIANT
};

class MultipleInheritenceBase {};

class Child1 : public MultipleInheritenceBase {};

class Child2 : public MultipleInheritenceBase {};

class GrandChild : public Child1, public Child2 {
  // no need to initialize MultipleInheritenceBase
  GrandChild() : Child1(), Child2() {} // COMPLIANT
};

class Base2 {};

class Derived6 : public Base2 {
public:
  Derived6() : b() {} // NON_COMPLIANT

private:
  Base2 b;
};