constexpr int f1(int i1) { return i1 + 1; }
int f2(); // ignored, not definition

int g1 = 1;                       // NON_COMPLIANT
constexpr int g1_correct = 1;     // COMPLIANT
int g2 = f1(1);                   // NON_COMPLIANT
constexpr int g2_correct = f1(1); // COMPLIANT
int g3 = f2(); // COMPLIANT - could be `const` but not `constexpr`
int g4 = 1;    // COMPLIANT - modified in test

class LiteralClass {};

LiteralClass lc;                      // NON_COMPLIANT
constexpr LiteralClass lc_correct;    // COMPLIANT
LiteralClass lca{};                   // NON_COMPLIANT
constexpr LiteralClass lca_correct{}; // COMPLIANT

class LiteralClass2 {
public:
  constexpr LiteralClass2() {}
};

LiteralClass2 lc2;                      // NON_COMPLIANT
constexpr LiteralClass2 lc2_correct;    // COMPLIANT
LiteralClass2 lc2a{};                   // NON_COMPLIANT
constexpr LiteralClass2 lc2a_correct{}; // COMPLIANT

class NonLiteralClass {
public:
  NonLiteralClass() {} // NON_COMPLIANT
};

NonLiteralClass nlc; // COMPLIANT

void test() {
  g4++;
  // This is never used, but can't be a constexpr because it's not initialized
  int l1; // COMPLIANT
  // This is non-compliant, because static variables are always at least zero
  // initialized
  static int l2; // NON_COMPLIANT

  // Non-compliant - these are zero initialized
  LiteralClass lc;   // NON_COMPLIANT
  LiteralClass2 lc2; // NON_COMPLIANT
}

class MemberConstExpr {
public:
  MemberConstExpr() {}
  MemberConstExpr(int p3) : m3(p3) {}

private:
  int m1;     // COMPLIANT - is not always zero initialized
  int m2 = 0; // NON_COMPLIANT
  int m3 = 0; // COMPLIANT - can be set by constructor
};

int h1(int x, int y) { return x + y; }

constexpr int h1_const(int x, int y) { return x + y; }

int h2() {
  int x1 = h1(1, 1);                 // COMPLIANT
  int x2 = h1_const(1, 1);           // NON_COMPLIANT
  const int x3 = h1_const(1, 1);     // NON_COMPLIANT
  constexpr int x4 = h1_const(1, 1); // COMPLIANT
}

class MissingConstexprClass {
public:
  MissingConstexprClass() = default;               // NON_COMPLIANT
  MissingConstexprClass(int i) = delete;           // NON_COMPLIANT
  MissingConstexprClass(int i, LiteralClass lc) {} // NON_COMPLIANT
private:
  int m1 = 0; // NON_COMPLIANT
};

extern int random();
constexpr int add(int x, int y) { return x + y; }
// Example with compile time constant literal value as default argument
constexpr int add1(int x, int y = 1) { return x + y; }
// Example with compile time constant function call as default argument
constexpr int add2(int x, int y = add(add1(1), 2)) { return x + y; }
// Example with non compile time constant function call as default argument
constexpr int add3(int x, int y = random()) { return x + y; }
// Example with compile time constant literal value as default arguments
constexpr int add4(int x = 1, int y = 2) { return x + y; }

constexpr void fp_reported_in_466(int p) {
  int l1 = add(1, 2); // NON_COMPLIANT
  int l2 = add(1, p); // COMPLIANT

  int l3 = 0;
  if (p > 0) {
    l3 = 1;
  } else {
    l3 = p;
  }

  constexpr int l4 = add(1, 2); //  COMPLIANT

  int l5 =
      add(l3, 2); // COMPLIANT - l3 is not compile time constant on all paths
  int l6 = add(l4, 2); // NON_COMPLIANT
  int l7 = add(l1, 2); // COMPLIANT - l1 is not constexpr
  int l8 =
      add1(l4, 2); // NON_COMPLIANT - all arguments are compile time constants
  int l9 = add1(l1, 2); // COMPLIANT - l1 is not constexpr
  int l10 = add1(l4);   // NON_COMPLIANT - argument and the default value of the
                        // second argument are compile time constants
  int l11 = add1(l1);   // COMPLIANT - l1 is not constexpr
  int l12 = add1(1);    // NON_COMPLIANT
  int l13 =
      add1(1, l3); // COMPLIANT - l3 is not compile time constant on all paths
  int l14 =
      add1(l3);      // COMPLIANT - l3 is not compile time constant on all paths
  int l15 = add2(1); // NON_COMPLIANT - provided argument and default value are
                     // compile time constants
  int l16 = add2(1, 2);  // NON_COMPLIANT
  int l17 = add2(l4, 2); // NON_COMPLIANT
  int l18 = add2(l1, 2); // COMPLIANT - l1 is not constexpr
  int l19 =
      add2(l3); // COMPLIANT - l3 is not compile time constant on all paths
  int l20 =
      add2(l3, 1); // COMPLIANT - l3 is not compile time constant on all paths
  int l21 = add3(1, 1); // NON_COMPLIANT
  int l22 = add3(1); // COMPLIANT - default value for second argument is not a
                     // compile time constant
  int l23 =
      add3(1, l3);  // COMPLIANT - l3 is not compile time constant on all paths
  int l24 = add4(); // NON_COMPLIANT - default values are compile time constants
  int l25 = add4(1); // NON_COMPLIANT - default value for second argument is a
                     // compile time constant
  int l26 =
      add4(1, l3); // COMPLIANT - l3 is not compile time constant on all paths
}

template <typename T> T *init(T **t) {}

template <typename T> T *init() {
  T *t = nullptr; // COMPLIANT - initialized below
  init(&t);       // Init is ignored in uninitialized template
  return t;
}

void test_template_instantiation() { int *t = init<int>(); }
