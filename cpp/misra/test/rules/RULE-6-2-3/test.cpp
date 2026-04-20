#include <cstdint>

inline int16_t global_redefined = 0;  // NON_COMPLIANT[False negative]
inline int16_t global_unique = 0;     // COMPLIANT
inline int16_t global_redeclared = 0; // COMPLIANT
inline void func_redefined() {}       // NON_COMPLIANT
inline void func_unique() {}          // COMPLIANT
inline void func_redeclared() {}      // COMPLIANT

// Violates our implementation of 6.2.1, but legal in our implementation
// of 6.2.3
int16_t global_noninline = 0;       // COMPLIANT
int func_noninline() { return 42; } // COMPLIANT

struct StructRedefined {};  // NON_COMPLIANT
struct StructUnique {};     // COMPLIANT
struct StructRedeclared {}; // COMPLIANT
struct IncompleteStruct;    // COMPLIANT
struct {
} anonymousStruct1; // COMPLIANT

template <typename T> class TplRedefined {};  // NON_COMPLIANT
template <typename T> class TplUnique {};     // COMPLIANT
template <typename T> class TplRedeclared {}; // COMPLIANT

enum DuplicateEnum {};            // NON_COMPLIANT
enum class DuplicateEnumClass {}; // NON_COMPLIANT
enum {} anonymousEnum1;           // COMPLIANT
typedef int16_t DuplicateTypedef; // NON_COMPLIANT
using DuplicateUsing = int16_t;   // NON_COMPLIANT
union DuplicateUnion {};          // NON_COMPLIANT
union {
} anonymousUnion1; // COMPLIANT

namespace ns1 {
class Outer {     // NON_COMPLIANT
  class Inner {}; // NON_COMPLIANT
};

namespace {
class AnonymousClass {}; // COMPLIANT
} // namespace
} // namespace ns1

void f() {
  auto x = []() { return 42; }; // COMPLIANT
}

#include "compliant_specialization.h"
#include "noncompliant_specialization.h"
#include "template.h"
