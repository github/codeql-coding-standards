// Note: the COMPLIANT/NON_COMPLIANT comments are here for documentary purposes;
// we do not expect alerts in this file. These should be flagged in `test.cpp`.

#include <cstdint>

inline int16_t global_redefined = 0;     // NON_COMPLIANT[False negative]
extern inline int16_t global_redeclared; // COMPLIANT
inline void func_redefined() {}          // NON_COMPLIANT -- flagged in test.cpp
inline void func_redeclared();           // COMPLIANT
inline void func_overloaded(double) {}   // COMPLIANT

// Violates our implementation of 6.2.1, but legal in our implementation
// of 6.2.3
int16_t global_noninline = 0;       // COMPLIANT
int func_noninline() { return 42; } // COMPLIANT

struct StructRedefined {}; // NON_COMPLIANT
struct StructRedeclared;   // COMPLIANT
struct IncompleteStruct;   // COMPLIANT
struct {
} anonymousStruct2; // COMPLIANT

template <typename T> class TplRedefined {}; // NON_COMPLIANT
template <typename T> class TplRedeclared;   // COMPLIANT

enum DuplicateEnum {};            // NON_COMPLIANT
enum class DuplicateEnumClass {}; // NON_COMPLIANT
enum {} anonymousEnum1;           // COMPLIANT
typedef int16_t DuplicateTypedef; // NON_COMPLIANT
using DuplicateUsing = int16_t;   // NON_COMPLIANT
union DuplicateUnion {};          // NON_COMPLIANT
union {
} anonymousUnion2; // COMPLIANT

namespace ns1 {
class Outer {     // NON_COMPLIANT
  class Inner {}; // NON_COMPLIANT
};

namespace {
class AnonymousClass {}; // COMPLIANT
} // namespace
} // namespace ns1

void f2() {
  auto x = []() { return 42; }; // COMPLIANT
}