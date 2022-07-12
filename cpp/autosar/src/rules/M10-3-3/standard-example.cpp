class A {
public:
};
virtual void foo() = 0; // foo declared pure
class B : public A {
public:
  virtual void foo() // foo defined
  {}
};
class C : public B {
public:
  virtual void foo() = 0; // Non-compliant – foo re-declared pure
};