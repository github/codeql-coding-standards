#include <cstdint>

struct TestStruct {
  std::int32_t m1;
  std::int32_t m2;
};

enum TestEnum { VALUE1, VALUE2 };

void test_integral_to_pointer_cast() {
  std::int32_t l1 = 42;
  std::int64_t l2 = 0x1000;

  // Casting integral types to pointer types
  TestStruct *l4 = reinterpret_cast<TestStruct *>(l1);     // NON_COMPLIANT
  TestStruct *l5 = reinterpret_cast<TestStruct *>(l2);     // NON_COMPLIANT
  std::int32_t *l7 = reinterpret_cast<std::int32_t *>(l2); // NON_COMPLIANT
}

void test_enumerated_to_pointer_cast() {
  TestEnum l1 = VALUE1;

  // Casting enumerated types to pointer types
  TestStruct *l3 = reinterpret_cast<TestStruct *>(l1);     // NON_COMPLIANT
  std::int32_t *l5 = reinterpret_cast<std::int32_t *>(l1); // NON_COMPLIANT
}

void test_void_pointer_to_object_pointer_cast() {
  void *l1 = nullptr;

  // Casting void pointer to object pointer types
  TestStruct *l2 = static_cast<TestStruct *>(l1);          // NON_COMPLIANT
  TestStruct *l3 = reinterpret_cast<TestStruct *>(l1);     // NON_COMPLIANT
  std::int32_t *l4 = static_cast<std::int32_t *>(l1);      // NON_COMPLIANT
  std::int32_t *l5 = reinterpret_cast<std::int32_t *>(l1); // NON_COMPLIANT
}

void test_integral_to_void_pointer_cast() {
  std::int32_t l1 = 42;
  std::int64_t l2 = 0x1000;

  // Casting integral types to void pointer
  void *l3 = reinterpret_cast<void *>(l1); // NON_COMPLIANT
  void *l4 = reinterpret_cast<void *>(l2); // NON_COMPLIANT
}

void test_compliant_void_pointer_casts() {
  void *l1 = nullptr;
  const void *l2 = nullptr;

  // Casts between void pointers are allowed
  const void *l3 = const_cast<const void *>(l1);        // COMPLIANT
  void *l4 = const_cast<void *>(l2);                    // COMPLIANT
  volatile void *l5 = static_cast<volatile void *>(l1); // COMPLIANT
}

void f1() {}
void f2(int) {}

void test_compliant_function_pointer_exceptions() {
  std::int64_t l1 = 0x1000;

  // Function pointer casts are exceptions to this rule
  void (*l2)() = reinterpret_cast<void (*)()>(l1);       // COMPLIANT
  void (*l3)(int) = reinterpret_cast<void (*)(int)>(l1); // COMPLIANT
}

struct TestClass {
  void memberFunc();
  std::int32_t m1;
};

void test_compliant_member_function_pointer_exceptions() {
  void *l1 = nullptr;

  // Member function pointer casts are technically exceptions to this rule, but
  // are prohibited by the compiler.
  //   void (TestClass::*l2)() =
  //       reinterpret_cast<void (TestClass::*)()>(l1); // COMPLIANT
}

void test_compliant_regular_pointer_operations() {
  TestStruct l1;
  TestStruct *l2 = &l1;
  std::int32_t *l3 = &l1.m1;

  // Regular pointer operations that don't involve forbidden casts
  TestStruct *l4 = l2;   // COMPLIANT
  std::int32_t *l5 = l3; // COMPLIANT
}