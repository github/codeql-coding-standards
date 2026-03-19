void f1(int a); // COMPLIANT -- same name
void f2(int a); // COMPLIANT -- unnamed is fine

void f3(int a); // COMPLIANT -- diff number but for those that exist, same
void f4(int p, int b); // NON_COMPLIANT -- diff name
void f5(int b, int a); // NON_COMPLIANT -- swapped names

typedef int wi;
typedef int hi;
typedef long a;

a f6(wi w, wi h) { // NON_COMPLIANT
  return (a)w * h;
}

void f7(int b, int a) { // NON_COMPLIANT
  return;
}

void f8(int a) { // COMPLIANT
  return;
}

template <class T> void f9(T t); // COMPLIANT
template <>
void f9<int>(int i); // COMPLIANT - specialization is a diff declaration

class ClassA {
  virtual void methodA(int i); // NON_COMPLIANT
  virtual void methodB(int i); // COMPLIANT
};

class ClassB : ClassA {
  void methodA(int d) override;
  void methodB(int i) override;
};