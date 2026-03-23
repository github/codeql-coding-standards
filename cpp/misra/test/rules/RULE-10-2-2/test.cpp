#include <cstdint>

/* ========== 1. Global scope fixtures ========== */
static int32_t G1 = 1;
static int32_t G2 = 2;

/* ========== 2. Global scope enums ========== */
enum E_Global1 : int32_t {
  V1,
  V2,
  V3
}; // NON_COMPLIANT: unscoped at global scope
enum {
  GlobalAnon1,
  GlobalAnon2
}; // NON_COMPLIANT: unscoped anonymous at global scope
enum class E_Global2 : int32_t { V1, V2 }; // COMPLIANT: scoped enum

/* ========== 3. Nested namespaces ========== */
namespace N1 {
static int32_t N1_V1 = 1;

enum E1 : int32_t { G1 }; // NON_COMPLIANT: unscoped in namespace + hides ::G1
enum { N1_Anon1, N1_Anon2 }; // NON_COMPLIANT: unscoped anonymous in namespace
enum class E2 : int32_t { G1 }; // COMPLIANT: scoped enum

namespace N2 {
static int32_t N2_V1 = 1;

enum E3 : int32_t {
  N1_V1
}; // NON_COMPLIANT: unscoped in namespace + hides N1::N1_V1
enum E4 : int32_t { G2 }; // NON_COMPLIANT: unscoped in namespace + hides ::G2
enum class E5 : int32_t { N1_V1, G2 }; // COMPLIANT: scoped enum
} // namespace N2
} // namespace N1

/* ========== 4. Anonymous namespace ========== */
namespace {
enum E_Anon1 : int32_t {
  V1,
  V2
}; // NON_COMPLIANT: unscoped in anonymous namespace
enum {
  AnonAnon1,
  AnonAnon2
}; // NON_COMPLIANT: unscoped anonymous in anonymous namespace
enum class E_Anon2 : int32_t { V1 }; // COMPLIANT: scoped enum
} // namespace

/* ========== 5. Anonymous namespace inside named namespace ========== */
namespace N3 {
static int32_t N3_V1 = 1;

namespace {
enum E1 : int32_t { N3_V1 };       // NON_COMPLIANT: unscoped + hides N3::N3_V1
enum class E2 : int32_t { N3_V1 }; // COMPLIANT: scoped enum
} // namespace
} // namespace N3

/* ========== 6. Nested classes ========== */
class C1 {
  static int32_t C1_V1;

  enum E1 { G1 }; // COMPLIANT: unscoped in class (exception) + hides ::G1
  enum {
    C1_Anon1,
    C1_Anon2
  }; // COMPLIANT: unscoped anonymous in class (exception)
  enum class E2 { G1 }; // COMPLIANT: scoped enum

  class C2 {
    enum E3 { C1_V1 }; // COMPLIANT: unscoped in nested class (exception)
    enum E4 {
      G2
    }; // COMPLIANT: unscoped in nested class (exception) + hides ::G2

    struct S1 {
      enum E5 { C1_V1 };       // COMPLIANT: unscoped in struct (exception)
      enum class E6 { C1_V1 }; // COMPLIANT: scoped enum
    };
  };
};

/* ========== 7. Struct at global scope ========== */
struct S_Global {
  enum E1 { G1 }; // COMPLIANT: unscoped in struct (exception)
  enum {
    S_Anon1,
    S_Anon2
  }; // COMPLIANT: unscoped anonymous in struct (exception)
  enum class E2 { G1 }; // COMPLIANT: scoped enum
};

/* ========== 8. Class inside namespace ========== */
namespace N4 {
static int32_t N4_V1 = 1;

enum E1 : int32_t { G1 }; // NON_COMPLIANT: unscoped in namespace

class C1 {
  enum E2 {
    N4_V1
  }; // COMPLIANT: unscoped in class (exception) + hides N4::N4_V1
  enum E3 { G2 }; // COMPLIANT: unscoped in class (exception) + hides ::G2
  enum class E4 { N4_V1, G2 }; // COMPLIANT: scoped enum
};
} // namespace N4

/* ========== 9. Function body ========== */
void f1() {
  int F1_V1 = 1;

  enum E1 : int32_t { G1 }; // NON_COMPLIANT: unscoped in function + hides ::G1
  enum { F1_Anon1, F1_Anon2 }; // NON_COMPLIANT: unscoped anonymous in function
  enum class E2 : int32_t { G1 }; // COMPLIANT: scoped enum
}

/* ========== 10. Nested blocks ========== */
void f2() {
  int F2_V1 = 1;

  {
    int F2_V2 = 2;

    enum E1 : int32_t {
      F2_V1
    }; // NON_COMPLIANT: unscoped in block + hides outer F2_V1
    enum E2 : int32_t { G2 }; // NON_COMPLIANT: unscoped in block + hides ::G2

    {
      enum E3 : int32_t {
        F2_V2
      }; // NON_COMPLIANT: unscoped in nested block + hides outer F2_V2
      enum class E4 : int32_t { F2_V1, F2_V2, G1 }; // COMPLIANT: scoped enum
    }
  }
}

/* ========== 11. Local class in function ========== */
void f3() {
  int F3_V1 = 1;

  class LocalC1 {
    enum E1 { F3_V1 }; // COMPLIANT: unscoped in local class (exception)
    enum E2 {
      G1
    }; // COMPLIANT: unscoped in local class (exception) + hides ::G1
    enum {
      Local_Anon1
    }; // COMPLIANT: unscoped anonymous in local class (exception)
    enum class E3 { F3_V1, G1 }; // COMPLIANT: scoped enum
  };
}

/* ========== 12. Lambda body ========== */
auto lambda1 = []() {
  enum E1 : int32_t { G1 }; // NON_COMPLIANT: unscoped in lambda body
  enum { Lambda_Anon1 };    // NON_COMPLIANT: unscoped anonymous in lambda body
  enum class E2 : int32_t { G1 }; // COMPLIANT: scoped enum
};

/* ========== 13. Nested lambdas ========== */
namespace N5 {
auto lambda2 = []() {
  enum E1 : int32_t { G1 }; // NON_COMPLIANT: unscoped in lambda body

  auto nested_lambda = []() {
    enum E2 : int32_t { G2 }; // NON_COMPLIANT: unscoped in nested lambda body
    enum class E3 : int32_t { G1, G2 }; // COMPLIANT: scoped enum
  };
};
} // namespace N5

/* ========== 14. Lambda inside class ========== */
class C3 {
  static inline auto member_lambda = []() {
    enum E1 : int32_t {
      G1
    }; // NON_COMPLIANT: unscoped in lambda body (not class scope!)
    enum class E2 : int32_t { G1 }; // COMPLIANT: scoped enum
  };
};

int main() { return 0; }
