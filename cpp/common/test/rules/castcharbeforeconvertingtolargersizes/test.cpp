// NOTICE: THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.
#include <cstdint>

template <typename S, typename T> S get(T t) {
  S s = t; // COMPLIANT
  return s;
}

void test(std::int32_t i32, std::int8_t i8, char c) {
  i32 = c;                                   // NON_COMPLIANT
  i32 = get<std::int32_t, std::int32_t>(c);  // NON_COMPLIANT
  i32 = get<std::int32_t, std::int8_t>(c);   // COMPLIANT
  i32 = i8;                                  // COMPLIANT
  i32 = get<std::int32_t, std::int32_t>(i8); // COMPLIANT
  i32 = get<std::int32_t, std::int8_t>(i8);  // COMPLIANT
}
