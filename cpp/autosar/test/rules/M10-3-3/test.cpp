
class Base {
public:
  virtual void f() = 0;
  virtual void g(){};
};

class Derived : public Base {
public:
  virtual void f() = 0; // COMPLIANT
  virtual void g() = 0; // NON_COMPLIANT
};
