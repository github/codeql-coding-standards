#include <cstdint>

class TestClass1 {
public:
  TestClass1(std::int32_t a);    // NON_COMPLIANT
  operator std::int32_t() const; // NON_COMPLIANT
};

class TestClass2 {
public:
  explicit TestClass2(std::int32_t a); // COMPLIANT
  explicit operator bool() const;      // COMPLIANT
};

class TestClass3 {
public:
  TestClass3(const TestClass3 &other); // COMPLIANT - copy constructor
  TestClass3(TestClass3 &&other);      // COMPLIANT - move constructor
};

class TestClass4 {
public:
  TestClass4(std::int32_t a,
             std::int32_t b = 0); // NON_COMPLIANT - callable with one argument
  TestClass4(char a = 'a',
             std::int32_t b = 0); // NON_COMPLIANT - callable with one argument
  TestClass4(char a, char b);     // COMPLIANT - requires two arguments
};

class TestClass5 {
public:
  explicit TestClass5(std::int32_t a, std::int32_t b = 0); // COMPLIANT
  explicit TestClass5(char a = 'a', std::int32_t b = 0);   // COMPLIANT
};

class TestClass6 {
public:
  TestClass6(std::int32_t a, std::int32_t b,
             std::int32_t c = 0); // COMPLIANT - requires at least two arguments
};

class TestClass7 {
public:
  operator double() const;          // NON_COMPLIANT
  operator const char *() const;    // NON_COMPLIANT
  explicit operator void *() const; // COMPLIANT
};