/** Static functions with internal linkage */

static void f1() {}           // NON_COMPLIANT - never used
static int f2() { return 0; } // COMPLIANT - used in an initializer
static void f3() {} // COMPLIANT - explicitly called in another function
static void f5();   // ignore declarations
static void f4() {  // COMPLIANT - dead code cycle, but is called statically and
                    // explicitly as required by the rule
  f5();
}
static void f5() { // COMPLIANT - dead code cycle, but is called statically and
                   // explicitly as required by the rule
  f4();
}

static int foo = f2(); // Consider any variable initializer calling a function
                       // to be a sufficient use

void test_use_static() { f3(); }

template <class T> static T getAT() { // NON_COMPLIANT - never used
  T t;
  return t;
}
template <class T> static void setT(T t) { // COMPLIANT - used with setT<Foo>
}

class Foo {};

void test_template() {
  Foo foo;
  setT(foo);
}

/** Private member functions */

class A {
public:
  void g1() {
    g3();
    g4();
  }

private:
  void g2() {}         // NON_COMPLIANT - never called
  void g3() {}         // COMPLIANT - called by g1
  virtual void g4() {} // COMPLIANT - called by g1
};

class B : A {
private:
  virtual void g4() {} // COMPLIANT - potentially called by g1
};

template <class T> class C {
public:
  void setT(T t) { _setT(t); }

private:
  T getAT() { // NON_COMPLIANT - never used
    T t;
    return t;
  }
  void
  _setT(T t) { // COMPLIANT - used in C<A>, which should make C<B>.setT live
  }
};

void test_template_class() { // Ensure the templates are populated
  C<A> c1;
  A a;
  c1.setT(a);
  C<B> c;
}

/** Anonymous namespace functions */
namespace {
void h1() { // COMPLIANT - used below "statically and explicitly" as
            // required by the rule
}
void h2() { h1(); } // NON_COMPLIANT

namespace foo {
namespace bar {
void h3() {} // NON_COMPLIANT
} // namespace bar
} // namespace foo
} // namespace