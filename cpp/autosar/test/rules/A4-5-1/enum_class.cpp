enum class FunctionalLang {
  ML,
  SML,
  OCaml,
  Lisp,
  Scheme,
  Racket,
  Haskell,
  FSharp,
  Elm,
  Idris
};

FunctionalLang operator&(FunctionalLang left, FunctionalLang right) {
  return left;
}
FunctionalLang operator+(FunctionalLang left, int right) { return left; }
FunctionalLang operator-(FunctionalLang l, FunctionalLang r) { return r; }
FunctionalLang operator-(FunctionalLang fl) { return FunctionalLang::ML; }
FunctionalLang operator%(FunctionalLang left, int right) { return left; }
FunctionalLang operator/(FunctionalLang left, int right) { return left; }
FunctionalLang operator*(FunctionalLang left, int right) { return left; }

bool operator&&(FunctionalLang left, FunctionalLang right) { return true; }
bool operator||(FunctionalLang left, FunctionalLang right) { return true; }
bool operator!(FunctionalLang fl) { return true; }

FunctionalLang operator|(FunctionalLang l, FunctionalLang r) { return r; }
FunctionalLang operator~(FunctionalLang fl) { return fl; }
FunctionalLang operator^(FunctionalLang l, FunctionalLang r) { return l; }
FunctionalLang operator>>(FunctionalLang left, int right) { return left; }
FunctionalLang operator<<(FunctionalLang left, int right) { return left; }
FunctionalLang operator&=(FunctionalLang l, FunctionalLang r) { return l; }
FunctionalLang operator^=(FunctionalLang l, int right) { return l; }
FunctionalLang operator>>=(FunctionalLang l, int right) { return l; }
FunctionalLang operator<<=(FunctionalLang l, int right) { return l; }

void test_enum_class() {
  enum FunctionalLang l = FunctionalLang::Lisp;     // COMPLIANT
  FunctionalLang::Lisp == FunctionalLang::Scheme;   // COMPLIANT
  FunctionalLang::Haskell != FunctionalLang::ML;    // COMPLIANT
  FunctionalLang::Lisp < FunctionalLang::Haskell;   // COMPLIANT
  FunctionalLang::Elm <= FunctionalLang::Haskell;   // COMPLIANT
  FunctionalLang::Idris > FunctionalLang::SML;      // COMPLIANT
  FunctionalLang::Haskell >= FunctionalLang::Idris; // COMPLIANT
  FunctionalLang::FSharp &FunctionalLang::OCaml;    // COMPLIANT

  // arithmetic
  FunctionalLang::ML + 1;                   // NON_COMPLIANT
  FunctionalLang::SML - FunctionalLang::ML; // NON_COMPLIANT
  -FunctionalLang::Haskell;                 // NON_COMPLIANT
  FunctionalLang::Racket % 0;               // NON_COMPLIANT
  FunctionalLang::Elm / 1;                  // NON_COMPLIANT
  FunctionalLang::Scheme * 2;               // NON_COMPLIANT

  // logical
  FunctionalLang::Haskell &&FunctionalLang::Elm;  // NON_COMPLIANT
  FunctionalLang::Lisp || FunctionalLang::Racket; // NON_COMPLIANT
  !FunctionalLang::Scheme;                        // NON_COMPLIANT

  // bitwise
  FunctionalLang::Elm | FunctionalLang::Racket; // NON_COMPLIANT
  ~FunctionalLang::Idris;                       // NON_COMPLIANT
  FunctionalLang::ML ^ FunctionalLang::OCaml;   // NON_COMPLIANT
  FunctionalLang::OCaml >> 1;                   // NON_COMPLIANT
  FunctionalLang::Lisp << 1;                    // NON_COMPLIANT
  l &= FunctionalLang::OCaml;                   // NON_COMPLIANT
  l ^= 1;                                       // NON_COMPLIANT
  l >>= 1;                                      // NON_COMPLIANT
  l <<= 1;                                      // NON_COMPLIANT
}

void test_enum_class_vars() {
  FunctionalLang a = FunctionalLang::Lisp;   // COMPLIANT
  FunctionalLang b = FunctionalLang::Scheme; // COMPLIANT
  a == a;                                    // COMPLIANT
  a != b;                                    // COMPLIANT
  a < b;                                     // COMPLIANT
  a <= b;                                    // COMPLIANT
  a > a;                                     // COMPLIANT
  a >= a;                                    // COMPLIANT
  a &b;                                      // COMPLIANT

  // arithmetic
  a + 1; // NON_COMPLIANT
  a - b; // NON_COMPLIANT
  -a;    // NON_COMPLIANT
  a % 0; // NON_COMPLIANT
  a / 1; // NON_COMPLIANT
  b * 2; // NON_COMPLIANT

  // logical
  a &&b;  // NON_COMPLIANT
  a || b; // NON_COMPLIANT
  !a;     // NON_COMPLIANT

  // bitwise
  a | b;  // NON_COMPLIANT
  ~a;     // NON_COMPLIANT
  a ^ b;  // NON_COMPLIANT
  a >> 1; // NON_COMPLIANT
  a << 1; // NON_COMPLIANT
}