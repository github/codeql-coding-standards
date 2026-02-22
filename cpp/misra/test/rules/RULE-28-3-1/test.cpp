#include <algorithm>
#include <cstdint>
#include <functional>
// #include <set>
#include <vector>

// Test cases for Rule 28.3.1#NonConstPredicateFunctionObject
// This query checks that predicate function objects have const operator()

struct F1 {
  bool operator()(std::int32_t l1, std::int32_t l2) { return l1 > l2; }
};

void test_function_object_non_const_in_set() {
  // TODO: implement stubs for set comparator.
  // std::set<std::int32_t, F1> l1; // NON_COMPLIANT
}

void test_function_object_non_const_in_sort() {
  std::vector<std::int32_t> l1 = {5, 2, 8, 1, 9};
  std::sort(l1.begin(), l1.end(), F1{}); // NON_COMPLIANT
}

struct F2 {
  bool operator()(std::int32_t l1, std::int32_t l2) const { return l1 > l2; }
};

void test_function_object_const_in_set() {
  // TODO: implement stubs for set comparator.
  // std::set<std::int32_t, F2> l1; // COMPLIANT
}

void test_function_object_const_in_sort() {
  std::vector<std::int32_t> l1 = {5, 2, 8, 1, 9};
  std::sort(l1.begin(), l1.end(), F2{}); // COMPLIANT
}

// Compliant: Using standard library predicates (always have const operator())
void test_standard_library_predicates() {
  std::vector<std::int32_t> l1 = {1, 2, 3, 4, 5};
  // TODO: implement stubs for greater comparator.
  // std::sort(l1.begin(), l1.end(), std::greater<std::int32_t>()); // COMPLIANT
}