
struct S {
  virtual void f() {}
};

void func(S &s); // to be lmplemented by the library, calls S::f()