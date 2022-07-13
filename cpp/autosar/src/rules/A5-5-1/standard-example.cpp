// $Id: A5-5-1.cpp 302200 2017-12-20 17:17:08Z michal.szczepankiewicz $

class A {
public:
  virtual ~A() = default;
};

class AA : public A {
public:
  virtual ~AA() = default;
  virtual void foo() {}

  using ptr = void (AA::*)();
};

class B {
public:
  static AA::ptr foo_ptr2;
};

AA::ptr B::foo_ptr2;

int main(void) {
  A *a = new A();
  void (A::*foo_ptr1)() = static_cast<void (A::*)()>(&AA::foo);
  (a->*foo_ptr1)(); // non-compliant
  delete a;

  AA *aa = new AA();
  (aa->*B::foo_ptr2)(); // non-compliant, not explicitly initialized
  delete aa;

  return 0;
}