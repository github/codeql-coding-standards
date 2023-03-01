// NOTICE: SOME OF THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.

class A {}; // NON_COMPLIANT - unused

class B { // NON_COMPLIANT - only used within itself
public:
  B f();
  void g(B b);
};

class C {};  // COMPLIANT - used in the type def
typedef C D; // NON_COMPLIANT - typedef itself not used

template <class T> // `T` is a `TemplateParameter` and shouldn't be flagged by
                   // the query
class E {          // COMPLIANT - used in test_template_class below
private:
  T m_t;

public:
  E(T t) : m_t(t) {}
};

void test_template_class() { E<int> e(0); }

class F {}; // COMPLIANT - used as a global function return type

F test_return_value() {
  F f;
  return f;
}

class G {}; // COMPLIANT - used as a global function parameter type

void test_return_value(G g) {}

class H {}; // COMPLIANT, used with template function

template <class T> T get() {
  T t;
  return t;
}

void test_template_function() { get<H>(); }

template <class T> class I : T::Base {};

class J {
public:
  class Base {}; // COMPLIANT - I<J> has J::Base as a base class
};

void test_template_base() { I<J> i{}; }

template <class T> class K { // COMPLIANT - used in function below, statically
public:
  static T f();
};

class L {}; // COMPLIANT - used in function below as type argument

void test_static_call() { L l = K<L>::f(); }

enum M { C1, C2, C3 };       // COMPLIANT - used in an enum type access below
enum class N { C4, C5, C6 }; // COMPLIANT - used in an enum type access below

void test_enum_access() {
  int i = C1;
  N::C4;
}

class O {}; // COMPLIANT - used in typedef below

typedef O P; // COMPLIANT - used in typedef below
typedef P Q; // COMPLIANT - used in function below
typedef Q R; // NON_COMPLIANT - never used

Q test_type_def() {}

struct {     // COMPLIANT - used in type definition
  union {    // COMPLIANT - f1 and f3 is accessed
    struct { // COMPLIANT - f1 is accessed
      int f1;
    };
    struct { // COMPLIANT - f3 is accessed
      float f2;
      float f3;
    };
    struct { // NON_COMPLIANT - f4 is never accessed
      long f4;
    };
  };
  int f5;
} s;

void test_nested_struct() {
  s.f1;
  s.f3;
  s.f5;
}

template <class T> class X { // COMPLIANT - template class never instantiated
  using custom_type = E<T>;  // COMPLIANT - template class never instantiated
};

template <class T> class Y {}; // COMPLIANT - used in the test case below

// Alias templates
template <typename T> using Z = Y<T>;  // COMPLIANT - used below
template <typename T> using AA = Y<T>; // NON_COMPLIANT - never instantiated

void test_alias_template() { Z<int> v; }
