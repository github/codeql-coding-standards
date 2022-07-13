class NonInterfaceBase1 {
  int m1;
};

class InterfaceBase1 {
public:
  static const int m2;
  virtual void f1() = 0;
};

class InterfaceDerived1 : public InterfaceBase1 {
public:
  void f1() {}
};

class A : public InterfaceBase1 {
public:
  void f1() {}
};
class B : NonInterfaceBase1 {};
class C : public NonInterfaceBase1 {};
class D : InterfaceBase1 {};