#include <cstdint>

// Non-compliant global variables (namespace scope, dynamically initialized or
// mutable)
std::int32_t f1();

std::int32_t g1{f1()}; // NON_COMPLIANT - dynamic initialization
const std::int32_t g2{
    g1}; // NON_COMPLIANT - dynamic initialization (depends on g1)
const std::int32_t g3{42};    // COMPLIANT - const with static initialization
constexpr std::int32_t g4{0}; // COMPLIANT - constexpr

namespace {
std::int32_t g5{0}; // NON_COMPLIANT - mutable namespace scope variable
constexpr std::int32_t g6{100}; // COMPLIANT - constexpr
const std::int32_t g7{100};     // COMPLIANT - const with static initialization

constexpr std::int32_t f2() { return 42; }
constexpr std::int32_t g8{f2()}; // COMPLIANT - constexpr
} // namespace

struct ComplexInit {
  ComplexInit() {}
};

const ComplexInit g9{}; // NON_COMPLIANT - dynamic initialization
std::int32_t g10{0};    // NON_COMPLIANT - mutable namespace scope variable
const std::int32_t g11{f1()}; // NON_COMPLIANT - dynamic initialization

class StaticMember {
  std::int32_t m1;
  static std::int32_t m2; // NON_COMPLIANT - class static data member
  static std::int32_t m3; // marked non_compliant at definition below
  static constexpr std::int32_t m4{0}; // COMPLIANT - constexpr static member
  static const std::int32_t m5;
};

std::int32_t StaticMember::m3 =
    0; // NON_COMPLIANT - class static data member definition
const std::int32_t StaticMember::m5 =
    42; // COMPLIANT - const with static initialization

constexpr auto g12 = // COMPLIANT - constexpr lambda
    [](auto x, auto y) { return x + y; };