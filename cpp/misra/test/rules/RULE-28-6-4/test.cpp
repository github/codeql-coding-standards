#include <algorithm>
#include <cstdint>
#include <deque>
#include <string>
#include <vector>

// Test cases for std::remove
void test_remove_result_unused() {
  std::vector<std::int32_t> v1 = {1, 2, 3, 2, 4};
  std::remove(v1.begin(), v1.end(), 2); // NON_COMPLIANT
}

void test_remove_result_used() {
  std::vector<std::int32_t> v1 = {1, 2, 3, 2, 4};
  auto l1 = std::remove(v1.begin(), v1.end(), 2); // COMPLIANT
  v1.erase(l1, v1.end());
}

void test_remove_result_used_in_erase() {
  std::vector<std::int32_t> v1 = {1, 2, 3, 2, 4};
  v1.erase(std::remove(v1.begin(), v1.end(), 2), v1.end()); // COMPLIANT
}

// Test cases for std::remove_if
void test_remove_if_result_unused() {
  std::vector<std::int32_t> v1 = {1, 2, 3, 4, 5};
  std::remove_if(v1.begin(), v1.end(),
                 [](std::int32_t l1) { return l1 % 2 == 0; }); // NON_COMPLIANT
}

void test_remove_if_result_used() {
  std::vector<std::int32_t> v1 = {1, 2, 3, 4, 5};
  auto l1 = std::remove_if(v1.begin(), v1.end(), [](std::int32_t l2) {
    return l2 % 2 == 0;
  }); // COMPLIANT
  v1.erase(l1, v1.end());
}

void test_remove_if_result_used_in_erase() {
  std::vector<std::int32_t> v1 = {1, 2, 3, 4, 5};
  v1.erase(std::remove_if(v1.begin(), v1.end(),
                          [](std::int32_t l1) { return l1 % 2 == 0; }),
           v1.end()); // COMPLIANT
}

// Test cases for std::unique
void test_unique_result_unused() {
  std::vector<std::int32_t> v1 = {0, 0, 1, 1, 2, 2, 3, 3};
  std::unique(v1.begin(), v1.end()); // NON_COMPLIANT
}

void test_unique_result_used() {
  std::vector<std::int32_t> v1 = {0, 0, 1, 1, 2, 2, 3, 3};
  auto l1 = std::unique(v1.begin(), v1.end()); // COMPLIANT
  v1.erase(l1, v1.end());
}

void test_unique_result_used_in_erase() {
  std::vector<std::int32_t> v1 = {0, 0, 1, 1, 2, 2, 3, 3};
  v1.erase(std::unique(v1.begin(), v1.end()), v1.end()); // COMPLIANT
}

void test_unique_with_predicate_result_unused() {
  std::vector<std::int32_t> v1 = {1, 2, 3, 4, 5, 6};
  std::unique(v1.begin(), v1.end(), [](std::int32_t l1, std::int32_t l2) {
    return (l1 % 2) == (l2 % 2);
  }); // NON_COMPLIANT
}

void test_unique_with_predicate_result_used() {
  std::vector<std::int32_t> v1 = {1, 2, 3, 4, 5, 6};
  auto l1 =
      std::unique(v1.begin(), v1.end(), [](std::int32_t l2, std::int32_t l3) {
        return (l2 % 2) == (l3 % 2);
      }); // COMPLIANT
  v1.erase(l1, v1.end());
}

// Test cases for empty (member function)
void test_empty_member_result_unused() {
  std::vector<std::int32_t> v1 = {1, 2, 3};
  v1.empty(); // NON_COMPLIANT
}

void test_empty_member_result_used_in_condition() {
  std::vector<std::int32_t> v1 = {1, 2, 3};
  if (v1.empty()) { // COMPLIANT
    v1.clear();
  }
}

void test_empty_member_result_used_in_assignment() {
  std::vector<std::int32_t> v1 = {1, 2, 3};
  bool l1 = v1.empty(); // COMPLIANT
}

// Test cases for std::empty (non-member function)
void test_empty_nonmember_result_unused() {
  std::vector<std::int32_t> v1 = {1, 2, 3};
  std::empty(v1); // NON_COMPLIANT
}

void test_empty_nonmember_result_used_in_condition() {
  std::vector<std::int32_t> v1 = {1, 2, 3};
  if (!std::empty(v1)) { // COMPLIANT
    v1.clear();
  }
}

void test_empty_nonmember_result_used_in_assignment() {
  std::vector<std::int32_t> v1 = {1, 2, 3};
  bool l1 = std::empty(v1); // COMPLIANT
}

void test_remove_with_deque() {
  std::deque<std::int32_t> d1 = {1, 2, 3, 2, 4};
  std::remove(d1.begin(), d1.end(), 2); // NON_COMPLIANT
}

void test_empty_with_string() {
  std::string s1 = "hello";
  s1.empty(); // NON_COMPLIANT
}

void test_empty_with_string_compliant() {
  std::string s1 = "hello";
  if (s1.empty()) { // COMPLIANT
    s1 = "default";
  }
}

// Edge case: result stored but not used
void test_remove_result_stored_but_not_used() {
  std::vector<std::int32_t> v1 = {1, 2, 3, 2, 4};
  auto l1 = std::remove(v1.begin(), v1.end(), 2); // COMPLIANT
}

// Edge case: chaining operations
void test_remove_chained_operations() {
  std::vector<std::int32_t> v1 = {1, 2, 3, 2, 4};
  std::vector<std::int32_t> v2 = {5, 6, 7};
  v1.erase(std::remove(v1.begin(), v1.end(), 2), v1.end()); // COMPLIANT
  v2.erase(std::remove(v2.begin(), v2.end(), 6), v2.end()); // COMPLIANT
}