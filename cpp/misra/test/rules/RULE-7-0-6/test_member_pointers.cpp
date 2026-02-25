#include <cstdint>

std::int16_t s16;
std::uint16_t u16;
std::int32_t s32;
std::uint32_t u32;
std::int64_t s64;
std::uint64_t u64;

struct MemberFunctionPointerTest {
  void mf15(std::int32_t l1) {}
  void mf15(std::uint32_t l1) {}
  void mf16(std::int32_t l1) {}
};

void test_pointer_to_member_functions() {
  MemberFunctionPointerTest l1;
  MemberFunctionPointerTest *l6 = &l1;

  // mf15 is overload independent when used as a member function pointer
  void (MemberFunctionPointerTest::*l2)(std::int32_t) =
      &MemberFunctionPointerTest::mf15;
  (l1.*l2)(s16); // COMPLIANT - widening of id-expression
  (l1.*l2)(s32); // COMPLIANT - type match
  (l1.*l2)(s64); // NON_COMPLIANT - narrowing
  (l1.*l2)(u16); // NON_COMPLIANT - wrong sign
  (l1.*l2)(u32); // NON_COMPLIANT - wrong sign
  (l1.*l2)(u64); // NON_COMPLIANT - wrong sign and narrowing

  (l6->*l2)(s16); // COMPLIANT - is widening of id-expression
  (l6->*l2)(s32); // COMPLIANT - type match
  (l6->*l2)(s64); // NON_COMPLIANT - narrowing
  (l6->*l2)(u16); // NON_COMPLIANT - wrong sign
  (l6->*l2)(u32); // NON_COMPLIANT - wrong sign
  (l6->*l2)(u64); // NON_COMPLIANT - wrong sign and narrowing

  // mf16 is overload independent when used as a member function pointer
  void (MemberFunctionPointerTest::*l3)(std::int32_t) =
      &MemberFunctionPointerTest::mf16;
  (l1.*l3)(s16); // COMPLIANT - widening of id-expression
  (l1.*l3)(s32); // COMPLIANT - type match
  (l1.*l3)(s64); // NON_COMPLIANT - narrowing
  (l1.*l3)(u16); // NON_COMPLIANT - wrong sign
  (l1.*l3)(u32); // NON_COMPLIANT - wrong sign
  (l1.*l3)(u64); // NON_COMPLIANT - wrong sign and narrowing

  (l6->*l3)(s16); // COMPLIANT - widening of id-expression
  (l6->*l3)(s32); // COMPLIANT - type match
  (l6->*l3)(s64); // NON_COMPLIANT - narrowing
  (l6->*l3)(u16); // NON_COMPLIANT - wrong sign
  (l6->*l3)(u32); // NON_COMPLIANT - wrong sign
  (l6->*l3)(u64); // NON_COMPLIANT - wrong sign and narrowing

  // Direct calls for comparison

  // mf15 is not overload-independent, so it should only be compliant
  // where an exact type of an overload is used
  l1.mf15(s16); // NON_COMPLIANT - widening not allowed
  l1.mf15(s32); // COMPLIANT - exact type match
  l1.mf15(u16); // NON_COMPLIANT - widening not allowed
  l1.mf15(u32); // COMPLIANT - exact type match

  // A qualified call to mf16 is overload-independent
  l1.mf16(s16); // COMPLIANT - widening of id-expression
  l1.mf16(s32); // COMPLIANT - exact type match
  l1.mf16(u16); // NON_COMPLIANT
  l1.mf16(u32); // NON_COMPLIANT
}

// Test static member function pointers - should be overload-independent
struct StaticMemberFunctionPointerTest {
  static void mf19(std::int32_t l1) {}
  static void mf19(std::uint32_t l1) {}
  static void mf20(std::int32_t l1) {}
};

void test_static_member_function_pointers() {
  // Static member function pointers - overload-independent
  void (*l1)(std::int32_t) = &StaticMemberFunctionPointerTest::mf19;
  l1(s16); // COMPLIANT - widening of id-expression
  l1(s32); // COMPLIANT - type match
  l1(s64); // NON_COMPLIANT - narrowing
  l1(u16); // NON_COMPLIANT - wrong sign
  l1(u32); // NON_COMPLIANT - wrong sign
  l1(u64); // NON_COMPLIANT - wrong sign and narrowing

  void (*l2)(std::int32_t) = &StaticMemberFunctionPointerTest::mf20;
  l2(s16); // COMPLIANT - widening of id-expression
  l2(s32); // COMPLIANT - type match
  l2(s64); // NON_COMPLIANT - narrowing
  l2(u16); // NON_COMPLIANT - wrong sign
  l2(u32); // NON_COMPLIANT - wrong sign
  l2(u64); // NON_COMPLIANT - wrong sign and narrowing

  // Direct calls for comparison - not overload-independent
  StaticMemberFunctionPointerTest::mf19(
      s16); // NON_COMPLIANT - widening not allowed
  StaticMemberFunctionPointerTest::mf19(s32); // COMPLIANT - exact type match
  StaticMemberFunctionPointerTest::mf19(
      u16); // NON_COMPLIANT - widening not allowed
  StaticMemberFunctionPointerTest::mf19(u32); // COMPLIANT - exact type match

  StaticMemberFunctionPointerTest::mf20(
      s16); // COMPLIANT - widening of id-expression
  StaticMemberFunctionPointerTest::mf20(s32); // COMPLIANT - exact type match
  StaticMemberFunctionPointerTest::mf20(u16); // NON_COMPLIANT
  StaticMemberFunctionPointerTest::mf20(u32); // NON_COMPLIANT
}

// Test member data pointers - not function calls, but test assignment to them
struct MemberDataPointerTest {
  std::int64_t m1;
  std::int64_t m2 : 10;
};

void test_member_data_pointers() {
  MemberDataPointerTest l1;

  // Member data pointer assignments - follow normal assignment rules
  std::int64_t MemberDataPointerTest::*l2 = &MemberDataPointerTest::m1;

  l1.*l2 = s16; // COMPLIANT - widening conversion allowed
  l1.*l2 = s32; // COMPLIANT - widening conversion allowed
  l1.*l2 = s64; // COMPLIANT
  l1.*l2 = u16; // NON_COMPLIANT - signedness violation
  l1.*l2 = u32; // NON_COMPLIANT - different signedness/size
  l1.*l2 = u64; // NON_COMPLIANT - different signedness
}