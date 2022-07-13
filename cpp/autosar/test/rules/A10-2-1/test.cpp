
class Base {
public:
  void f1(int x){};
  virtual void f2(){};

private:
  void priv_f1(){};
};

class Derived : public Base {
public:
  void f1(int x){}; // NON_COMPLIANT

  void f2(){}; // COMPLIANT

private:
  void priv_f1(){}; // COMPLIANT
};

class PrivateDerived : private Base {
public:
  void f1(int x){}; // COMPLIANT
};