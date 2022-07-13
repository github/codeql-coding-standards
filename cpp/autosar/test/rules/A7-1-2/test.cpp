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