#include <cstdint>

// Test case: Class with mixed public and private non-static data members
class MixedAccessClass {
public:
  std::int32_t m1; // NON_COMPLIANT
private:
  std::int32_t m2; // NON_COMPLIANT
};

// Test case: Class with all public non-static data members
class AllPublicClass {
public:
  std::int32_t m1; // COMPLIANT
  std::int32_t m2; // COMPLIANT
  std::int32_t m3; // COMPLIANT
};

// Test case: Class with all private non-static data members
class AllPrivateClass {
private:
  std::int32_t m1; // COMPLIANT
  std::int32_t m2; // COMPLIANT
  std::int32_t m3; // COMPLIANT
};

// Test case: Struct with all public members (default access)
struct AllPublicStruct {
  std::int32_t m1; // COMPLIANT
  std::int32_t m2; // COMPLIANT
};

// Test case: Mixed access with static members should be compliant
class MixedWithStaticMembers {
public:
  static std::int32_t s1; // COMPLIANT
private:
  std::int32_t m1; // COMPLIANT
  std::int32_t m2; // COMPLIANT
};

// Test case: Class with protected and private members
class ProtectedAndPrivateClass {
protected:
  std::int32_t m1; // NON_COMPLIANT
private:
  std::int32_t m2; // NON_COMPLIANT
};

// Test case: Class with public and protected members
class PublicAndProtectedClass {
public:
  std::int32_t m1; // NON_COMPLIANT
protected:
  std::int32_t m2; // NON_COMPLIANT
};

// Test case: Class with all three access levels
class AllThreeAccessLevels {
public:
  std::int32_t m1; // NON_COMPLIANT
protected:
  std::int32_t m2; // NON_COMPLIANT
private:
  std::int32_t m3; // NON_COMPLIANT
};

// Test case: Class only protected members
class OnlyProtected {
protected:
  std::int32_t m1; // NON_COMPLIANT
  std::int32_t m2; // NON_COMPLIANT
  std::int32_t m3; // NON_COMPLIANT
};

// Test case: Empty class
class EmptyClass {
  // COMPLIANT - no data members
};

// Test case: Class with only static members
class OnlyStaticMembers {
public:
  static std::int32_t s1; // COMPLIANT
private:
  static std::int32_t s2; // COMPLIANT
};

// Test case: Class with only member functions
class OnlyMemberFunctions {
public:
  void f1() {} // COMPLIANT
private:
  void f2() {} // COMPLIANT
};
