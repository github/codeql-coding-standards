
class Base {
public:
  virtual void f(int x, int y = 1, int z = 2){};
  virtual void g(int x, int y){};
};

class Derived : public Base {
public:
  void f(int x, int y = 1, int z = 2) override{}; // COMPLIANT
  void g(int x, int y) override{}; // COMPLIANT - no default arguments
};

class Derived2 : public Base {
public:
  void f(int x, int y, int z = 2) override{}; // NON_COMPLIANT
};

class Derived3 : public Base {
public:
  void f(int x, int y = 1, int z = 3) override{}; // NON_COMPLIANT
};
