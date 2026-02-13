/** Test cases for `UnusedLocalVariable.ql` */

#define m1 int mx1 = 0;

int test_simple() {
  int x = 1; // COMPLIANT - used below
  int y = 2; // NON_COMPLIANT - never used
  m1         // we ignore unused variables in macros
      return x;
}

int test_maybe_unused() {
  [[maybe_unused]]
  int l0; // COMPLIANT - has attr unused
}

int test_const() {
  const int x = 1; // COMPLIANT - used below
  const int y = 2; // COMPLIANT - used in array initialization,
  int z[y];        // NON_COMPLIANT - never used
  return x;
}

template <class T> int f1() {
  int x = 1; // COMPLIANT - used in return value
  T t;       // NON_COMPLIANT - t is never used in any instantiation
             // Note: this gets reported twice, once for each instantiation
  return x;
}

class LA {};
class LB {};

void test_f1() {
  f1<LA>();
  f1<LB>();
}

int gc1 = 0;

class LC {
public:
  LC() { gc1++; }
};

void test_side_effect_init() {
  LA a; // NON_COMPLIANT - no constructor called
  LC c; // COMPLIANT - constructor called which is considered to potentially
        // have side effects
}

#include <array>
#include <cstdio>
template <int t> class CharBuffer {
public:
  int member[t];
  CharBuffer() : member{0} {}
};

int test_constexpr_in_template_inst() {
  constexpr int line_length = 1024U; // COMPLIANT - used in template inst.
                                     // of buffer.
  CharBuffer<line_length> buffer{};
  return buffer.member[0];
}

enum DataType : unsigned char {
  int8,
  int16,
};

template <typename... Types> int test_constexpr_in_static_assert() {
  const std::array<DataType, sizeof...(Types)> lldts{int8};
  const std::array<DataType, sizeof...(Types)> llams{int16};
  constexpr std::size_t mssu = 64 * 1024; // COMPLIANT - used in static assert.
  static_assert((sizeof(lldts) + sizeof(llams)) <= mssu, "assert");
  return 0;
}

int baz() {
  test_constexpr_in_static_assert<int>();
  return 0;
}

template <bool... Args> extern constexpr bool all_of_v = true; // COMPLIANT

template <bool B1, bool... Args>
extern constexpr bool all_of_v<B1, Args...> =
    B1 && all_of_v<Args...>; // COMPLIANT

void test_template_variable() { all_of_v<true, true, true>; }

template <typename T> void template_function() {
  T t;       // NON_COMPLIANT - t is never used
  T t2;      // COMPLIANT - t is used
  t2.test(); // Call may not be resolved in uninstantiated template
}

class ClassT {
public:
  void test() {}
};

void test_template_function() { template_function<ClassT>(); }

int foo() {
  constexpr int arrayDim = 10; // COMPLIANT - used in array size below
  static int array[arrayDim]{};
  return array[4];
}

template <typename T> static T another_templ_function() { return T(); }

template <typename T, typename First, typename... Rest>
static T another_templ_function(const First &first, const Rest &...rest) {
  return first +
         another_templ_function<T>(rest...); // COMPLIANT - 'rest' is used here
}

static int templ_fnc2() { return another_templ_function<int>(1, 2, 3, 4, 5); }
