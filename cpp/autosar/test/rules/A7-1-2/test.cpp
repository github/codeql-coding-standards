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

int h1(int x, int y) { // NON_COMPLIANT
  return x + y;
}

constexpr int h1_correct(int x, int y) { // COMPLIANT
  return x + y;
}

int h2(int x) { return h1(x, 1) + 1; } // NON_COMPLIANT
constexpr int h2_correct(int x) { return h1_correct(x, 1) + 1; } // COMPLIANT

int h3(int x) { // COMPLIANT - uses goto, so can't be constexpr
  if (x) {
    goto l1;
  } else {
    return 10;
  }
l1:
  return 1;
}

int h4(int x) { // COMPLIANT - uses try, so can't be constexpr
  try {
    return 1;
  } catch (...) {
  }
}

int h5(int x) { // COMPLIANT - declares non literal local var
  NonLiteralClass nlc;
}

int h6(int x) { // COMPLIANT - declares static variable
  static int i = x;
  return x;
}

int h7(int x) { // COMPLIANT - declares no init variable
  int i;
}

int h8(int x) { // NON_COMPLIANT - could be constexpr
  int i = x;
  return i;
}

constexpr int h8_correct(int x) { // COMPLIANT
  int i = x;
  return i;
}

int h9(int x) { // COMPLIANT - declares thread local variable
  thread_local int i = x;
  return x;
}

class ConstexprFunctionClass {
public:
  int mf1(int x) { return m1 + x; }                   // NON_COMPLIANT
  constexpr int mf1_correct(int x) { return m1 + x; } // COMPLIANT

private:
  int m1;
};

class MissingConstexprClass {
public:
  MissingConstexprClass() = default;               // NON_COMPLIANT
  MissingConstexprClass(int i) = delete;           // NON_COMPLIANT
  MissingConstexprClass(int i, LiteralClass lc) {} // NON_COMPLIANT
private:
  int m1 = 0;
};

class VirtualBaseClass {};

class DerivedClass : public virtual VirtualBaseClass {
public:
  DerivedClass() = default;               // COMPLIANT
  DerivedClass(int i) = delete;           // COMPLIANT
  DerivedClass(int i, LiteralClass lc) {} // COMPLIANT
private:
  int m1 = 0;
};

class NotAllMembersInitializedClass {
public:
  NotAllMembersInitializedClass() = default;               // COMPLIANT
  NotAllMembersInitializedClass(int i) = delete;           // COMPLIANT
  NotAllMembersInitializedClass(int i, LiteralClass lc) {} // COMPLIANT
private:
  int m1;
};

class NonLiteralParamsClass {
public:
  NonLiteralParamsClass(int i, NonLiteralClass lc) {} // COMPLIANT
};

// Variant members are always initialized, so this can be marked constexpr
class VariantMemberInitialized {
public:
  VariantMemberInitialized() = default;               // NON_COMPLIANT
  VariantMemberInitialized(int i) = delete;           // NON_COMPLIANT
  VariantMemberInitialized(int i, LiteralClass lc) {} // NON_COMPLIANT
private:
  union {
    int i = 0;
    short s;
  };
};

class VariantMemberInitConstexpr {
public:
  constexpr VariantMemberInitConstexpr() = default;               // COMPLIANT
  constexpr VariantMemberInitConstexpr(int i) = delete;           // COMPLIANT
  constexpr VariantMemberInitConstexpr(int i, LiteralClass lc) {} // COMPLIANT
private:
  union {
    int i = 0;
    short s;
  };
};

// Variant members are not initialized at declaration, so we can only mark the
// constructors as constexpr if we explicitly initialize the variant member
class VariantMemberNotInit {
public:
  VariantMemberNotInit() = default;                         // COMPLIANT
  VariantMemberNotInit(int pi) = delete;                    // COMPLIANT
  VariantMemberNotInit(int pi, LiteralClass lc) {}          // COMPLIANT
  VariantMemberNotInit(LiteralClass lc, int pi) : i(pi) {}  // NON_COMPLIANT
  constexpr VariantMemberNotInit(LiteralClass lc, short pi) // COMPLIANT
      : i(pi) {}

private:
  union {
    int i;
    short s;
  };
};

class ExcludedCases {
public:
  ~ExcludedCases() {} // COMPLIANT

  void operator=(ExcludedCases &) {}  // COMPLIANT
  void operator=(ExcludedCases &&) {} // COMPLIANT
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
  int x = add(1, 2); // NON_COMPLIANT
  int y = add(1, p); // COMPLIANT

  int z = 0;
  if (p > 0) {
    z = 1;
  } else {
    z = p;
  }

  constexpr int t = add(1, 2); //  COMPLIANT

  int u = add(z, 2); // COMPLIANT - z is not compile time constant on all paths
  int v = add(t, 2); // NON_COMPLIANT
  int w =
      add1(t, 2);  // NON_COMPLIANT - all arguments are compile time constants
  int a = add1(t); // NON_COMPLIANT - s and the default value of the second
                   // argument are compile time constants
  int b = add1(1); // NON_COMPLIANT
  int c = add1(1, z); // COMPLIANT - z is not compile time constant on all paths
  int d = add1(z);    // COMPLIANT - z is not compile time constant on all paths
  int e = add2(1);    // NON_COMPLIANT - provided argument and default value are
                      // compile time constants
  int f = add2(1, 2); // NON_COMPLIANT
  int g = add2(t, 2); // NON_COMPLIANT
  int h = add2(z);    // COMPLIANT - z is not compile time constant on all paths
  int i = add2(z, 1); // COMPLIANT - z is not compile time constant on all paths
  int j = add3(1, 1); // NON_COMPLIANT
  int k = add3(1);    // COMPLIANT - default value for second argument is not a
                      // compile time constant
  int l = add3(1, z); // COMPLIANT - z is not compile time constant on all paths
  int m = add4();  // NON_COMPLIANT - default values are compile time constants
  int n = add4(1); // NON_COMPLIANT - default value for second argument is a
                   // compile time constant
  int o = add4(1, z); // COMPLIANT - z is not compile time constant on all paths
}