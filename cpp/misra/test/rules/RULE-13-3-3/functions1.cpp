void f1(int a); // COMPLIANT -- same name
void f2(int a); // COMPLIANT -- unnamed is fine

void f3(int a); // COMPLIANT -- diff number but for those that exist, same
void f4(int p, int b); // NON_COMPLIANT -- diff name
void f5(int b, int a); // NON_COMPLIANT -- swapped names

void f6(int b, int a) { // NON_COMPLIANT
  return;
}

void f7(int a) { // COMPLIANT
  return;
}

template <class T> void f8(T t); // COMPLIANT
template <>
void f8<int>(int i); // COMPLIANT - specialization is a diff declaration

class ClassA {
  virtual void methodA(int i); // NON_COMPLIANT
  virtual void methodB(int i); // COMPLIANT
};

class ClassB : ClassA {
  void methodA(int d) override;
  void methodB(int i) override;
};