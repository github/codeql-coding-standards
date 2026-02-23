#include <algorithm>
#include <cstdint>
#include <functional>
#include <set>
#include <vector>

// Test cases for Rule 28.3.1#NonConstPredicateFunctionObject
// This query checks that predicate function objects have const operator()

struct F1 {
  bool operator()(std::int32_t l1, std::int32_t l2) { return l1 > l2; }
};

void test_function_object_non_const_in_set() {
  std::set<std::int32_t, F1> l1; // NON_COMPLIANT
}

void test_function_object_non_const_in_sort() {
  std::vector<std::int32_t> l1 = {5, 2, 8, 1, 9};
  std::sort(l1.begin(), l1.end(), F1{}); // NON_COMPLIANT
}

struct F2 {
  bool operator()(std::int32_t l1, std::int32_t l2) const { return l1 > l2; }
};

void test_function_object_const_in_set() {
  std::set<std::int32_t, F2> l1; // COMPLIANT
}

void test_function_object_const_in_sort() {
  std::vector<std::int32_t> l1 = {5, 2, 8, 1, 9};
  std::sort(l1.begin(), l1.end(), F2{}); // COMPLIANT
}

// Compliant: Using standard library predicates (always have const operator())
void test_standard_library_predicates() {
  std::vector<std::int32_t> l1 = {1, 2, 3, 4, 5};
  std::sort(l1.begin(), l1.end(), std::greater<std::int32_t>()); // COMPLIANT
}

// Non-compliant: free function predicate modifying a static local variable
bool cmp_with_static(std::int32_t l1, std::int32_t l2) {
  static std::int32_t g_count = 0;
  ++g_count; // NON_COMPLIANT
  return l1 < l2;
}

void test_predicate_fn_static_local() {
  std::vector<std::int32_t> l1 = {5, 2, 8, 1, 9};
  std::sort(l1.begin(), l1.end(), cmp_with_static); // NON_COMPLIANT
}

// Non-compliant: free function predicate modifying a global variable
std::int32_t g_predicate_call_count = 0;

bool cmp_with_global(std::int32_t l1, std::int32_t l2) {
  ++g_predicate_call_count; // NON_COMPLIANT
  return l1 < l2;
}

void test_predicate_fn_global() {
  std::vector<std::int32_t> l1 = {5, 2, 8, 1, 9};
  std::sort(l1.begin(), l1.end(), cmp_with_global); // NON_COMPLIANT
}

// Non-compliant: function object whose operator() modifies a global variable
struct F3_SideEffect {
  bool operator()(std::int32_t l1, std::int32_t l2) const {
    ++g_predicate_call_count; // NON_COMPLIANT
    return l1 < l2;
  }
};

void test_function_object_with_global_side_effect() {
  std::vector<std::int32_t> l1 = {5, 2, 8, 1, 9};
  std::sort(l1.begin(), l1.end(), F3_SideEffect{}); // NON_COMPLIANT
}

// Compliant: free function predicate with no side effects
bool cmp_pure(std::int32_t l1, std::int32_t l2) { // COMPLIANT
  return l1 < l2;
}

void test_predicate_fn_pure() {
  std::vector<std::int32_t> l1 = {5, 2, 8, 1, 9};
  std::sort(l1.begin(), l1.end(), cmp_pure); // COMPLIANT
}

// Compliant: function object with const operator() and no side effects
struct F4_Pure {
  bool operator()(std::int32_t l1, std::int32_t l2) const { // COMPLIANT
    return l1 < l2;
  }
};

void test_function_object_pure() {
  std::vector<std::int32_t> l1 = {5, 2, 8, 1, 9};
  std::sort(l1.begin(), l1.end(), F4_Pure{}); // COMPLIANT
}