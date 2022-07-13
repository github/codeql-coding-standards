#include <limits>
#include <string>

int foo();
constexpr int bar() { return 10; }

static int i1;             // COMPLIANT - default zero initialized
static int i2 = foo();     // NON_COMPLIANT - foo() is not constexpr
static int i3 = 1 + foo(); // NON_COMPLIANT - foo() is not constexpr
static int i4 = bar();     // COMPLIANT - bar() is not constexpr
static int i5 = 1 + bar(); // COMPLIANT - bar() is not constexpr
static int i6{0};          // COMPLIANT
static int i7{foo()};      // NON_COMPLIANT

class ClassTrivial {};

static ClassTrivial t; // COMPLIANT - default initialized, calls
                       // the implicitly declared and defined constructor, which
                       // is a constexpr constructor in this case
static ClassTrivial t1{}; // COMPLIANT - value initialized, but
                          // triggers zero initialization

struct StructSimple {
  int i;
  int j;
};

static StructSimple s; // COMPLIANT - default initialized, calls
                       // the implicitly declared and defined constructor, which
                       // would be a constexpr constructor in this case
static StructSimple s1{}; // COMPLIANT - value initialized, but
                          // triggers zero initialization
static StructSimple s2{.i = 1, .j = bar()}; // COMPLIANT
static StructSimple s3{.i = 1, .j = foo()}; // NON_COMPLIANT

class ClassA {
public:
  ClassA() {}
  constexpr ClassA(int a) : m_a(a) {}
  ClassA(int a, int b) : m_a(a + b) {}

private:
  int m_a;
};

static ClassA a;     // NON_COMPLIANT - default initialized by calling default
                     //                 constructor which is not constexpr
static ClassA a1{};  // NON_COMPLIANT - value initialized, but will be default
                     //                 initialized with a constructor call to
                     //                 ClassA()
static ClassA a2{1}; // COMPLIANT - constant value with constexpr constructor
static ClassA a3{foo()}; // NON_COMPLIANT - non constant value with constexpr
                         //                 constructor
static ClassA a4{1, 2};  // NON_COMPLIANT - not a constexpr constructor

thread_local ClassA a5;    // NON_COMPLIANT - default initialized by calling
                           //                 default constructor which is not
                           //                 constexpr
thread_local ClassA a6{};  // NON_COMPLIANT - value initialized, but will be
                           //                 default initialized with a
                           //                 constructor call to ClassA()
thread_local ClassA a7{1}; // COMPLIANT - constant value with constant
                           //             initializer
thread_local ClassA a8{foo()}; // NON_COMPLIANT - const value with const
                               //                 initializer
thread_local ClassA a9{1, 2};  // NON_COMPLIANT - not a constexpr constructor

// String constructor is not constexpr (as it allocates)
static std::string string;               // NON_COMPLIANT
static std::string string1 = "A string"; // NON_COMPLIANT

class StaticMember {
  static int m1;
  static int m2;
};
int StaticMember::m1 = 0;     // COMPLIANT
int StaticMember::m2 = foo(); // NON_COMPLIANT

namespace test {
constexpr int maxInt32 = std::numeric_limits<int>::max(); // COMPLIANT
static int s = foo();                                     // NON_COMPLIANT
} // namespace test