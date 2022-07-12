
class A {
public:
  ~A(){}; // NON_COMPLIANT
};

class B final {
public:
  ~B(){}; // COMPLIANT
};
