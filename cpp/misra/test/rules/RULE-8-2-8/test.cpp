#include <cstddef>
#include <cstdint>
struct S {};
class C {};

S *g1 = nullptr;

using hashPtr_t = std::uintptr_t;
using MyIntPtr = std::intptr_t;

void test_compliant_uintptr_t_cast() {
  S *l1 = nullptr;
  auto l2 = reinterpret_cast<std::uintptr_t>(l1); // COMPLIANT
}

void test_compliant_intptr_t_cast() {
  C *l1 = nullptr;
  auto l2 = reinterpret_cast<std::intptr_t>(l1); // COMPLIANT
}

void test_compliant_void_pointer_cast() {
  void *l1 = nullptr;
  auto l2 = reinterpret_cast<std::uintptr_t>(l1); // COMPLIANT
  auto l3 = reinterpret_cast<std::intptr_t>(l1);  // COMPLIANT
}

void test_compliant_const_pointer_cast() {
  const int *l1 = nullptr;
  auto l2 = reinterpret_cast<std::uintptr_t>(l1); // COMPLIANT
  auto l3 = reinterpret_cast<std::intptr_t>(l1);  // COMPLIANT
}

void test_non_compliant_unsigned_long_cast() {
  S *l1 = nullptr;
  auto l2 = reinterpret_cast<unsigned long>(l1); // NON_COMPLIANT
}

void test_non_compliant_unsigned_int_cast() {
  S *l1 = nullptr;
  auto l2 = reinterpret_cast<unsigned int>(l1); // NON_COMPLIANT
}

void test_non_compliant_long_cast() {
  C *l1 = nullptr;
  auto l2 = reinterpret_cast<long>(l1); // NON_COMPLIANT
}

void test_non_compliant_size_t_cast() {
  void *l1 = nullptr;
  auto l2 = reinterpret_cast<std::size_t>(l1); // NON_COMPLIANT
}

void test_non_compliant_typedef_cast() {
  S *l1 = nullptr;
  auto l2 = reinterpret_cast<hashPtr_t>(l1); // NON_COMPLIANT
}

void test_non_compliant_using_alias_cast() {
  C *l1 = nullptr;
  auto l2 = reinterpret_cast<MyIntPtr>(l1); // NON_COMPLIANT
}

template <typename T> void test_non_compliant_template_cast() {
  S *l1 = nullptr;
  auto l2 = reinterpret_cast<T>(l1);              // NON_COMPLIANT
  auto l3 = reinterpret_cast<std::uintptr_t>(l1); // COMPLIANT
  auto l4 = reinterpret_cast<std::uint64_t>(l1);  // NON_COMPLIANT
}

void test_non_compliant_uint64_t_cast() {
  S *l1 = nullptr;
  auto l2 = reinterpret_cast<std::uint64_t>(l1); // NON_COMPLIANT
}

void test_non_compliant_int64_t_cast() {
  void *l1 = nullptr;
  auto l2 = reinterpret_cast<std::int64_t>(l1); // NON_COMPLIANT
}

template <typename T> class TestNonCompliantTemplateCast {
public:
  TestNonCompliantTemplateCast() {
    S *l1 = nullptr;
    auto l2 = reinterpret_cast<T>(l1);              // NON_COMPLIANT
    auto l3 = reinterpret_cast<std::uintptr_t>(l1); // COMPLIANT
    auto l4 = reinterpret_cast<std::uint64_t>(l1);  // NON_COMPLIANT
  }
};

template <class T>
T variable_template = reinterpret_cast<T>(g1); // NON_COMPLIANT

void test_instantiate_template() {
  test_non_compliant_template_cast<std::uintptr_t>();
  TestNonCompliantTemplateCast<std::uintptr_t> x{};
  variable_template<std::uintptr_t>;
}