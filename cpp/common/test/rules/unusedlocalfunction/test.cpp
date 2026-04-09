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

static int unevaluatedContextFn(int x) {
  x++;
  return x;
} // COMPLIANT - called in an unevaluated context.
#include <typeinfo>
static int unevalContextCaller() // COMPLIANT - address taken
{

  typeid(unevaluatedContextFn(0));
  sizeof(unevaluatedContextFn(1));
  noexcept(unevaluatedContextFn(2));
  decltype(unevaluatedContextFn(2)) n = 42;
  return 0;
}
int (*ptr_unevalContextCaller)(void) = unevalContextCaller;

class X {
private:
  [[maybe_unused]] void maybeUnused();
  void deleted() = delete; // COMPLIANT - Deleted Function
};

void X::maybeUnused() {} // COMPLIANT - [[maybe_unused]]

static int overload1(int c) // COMPLIANT - called
{
  return ++c;
}

static int overload1(int c, int d) // COMPLIANT - overload1(int) is called.
{
  return c + d;
}

int overload = overload1(5);

class classWithOverloads {
public:
  int caller(int x) { return overloadMember(x, 0); }

private:
  int overloadMember(int c) // COMPLIANT - overloadMember(int, int) is called.
  {
    return ++c;
  }
  int overloadMember(int c, int d) // COMPLIANT - called.
  {
    return c + d;
  }
};

namespace {
class C1 {
public:
  void f() {} // NON_COMPLIANT - never used, internal linkage
};

namespace named {
class C2 {
public:
  void f() {} // NON_COMPLIANT - never used, internal linkage
};
} // namespace named
} // namespace

namespace N1 {
class C3 {
public:
  void f() {} // COMPLIANT - public external linkage
};
} // namespace N1