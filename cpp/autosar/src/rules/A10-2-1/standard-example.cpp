// $Id: A10-2-1.cpp 317123 2018-04-23 08:48:11Z ilya.burylov $
class A {
public:
  virtual ~A() = default;
  void F() noexcept {}
  virtual void G() noexcept {}

private:
  void H() noexcept {}
};
class B : public A {
public:
  void F() noexcept {
  } // Non-compliant - F() function from A class hidden by B class
  void G() noexcept override {} // Compliant - G() function from A class
  // overridden by B class
private:
  void H() noexcept {} // Compliant - H() function is private in A class
};
class C : private A {
public:
  F() noexcept {} // Compliant by exception - private inheritance
};
void Fn1(A &object) noexcept {
  object.F(); // Calls F() function from A
  object.G(); // Calls G() function from B
}
void Fn2() noexcept {
  B b;
  Fn1(b);
}