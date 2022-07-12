class A {
public:
  const static int m = 1;
  void member_function(){};
  static int member_function_two() { return 1; }
};

struct B {};

class C {
public:
  void member_function(){};
};

template <class T> class D {
public:
  void d_member_function_one() {
    T t;
    t.member_function();
  }
  void d_member_function_two() {
    T t;
    int i;
    i = t.m;
  }
};

template <class T> class E {
public:
  const static int m = 1;
  void member_function(){};
};

class F : public E<B> {};

void f1() {
  D<A> a; // COMPLIANT
  a.d_member_function_one();
  a.d_member_function_two();

  D<B> b; // NON_COMPLIANT

  D<C> c; // NON_COMPLIANT
  D<F> f; // COMPLIANT
}