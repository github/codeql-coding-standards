#include <cstdint>
#include <iostream>
#include <memory>
#include <utility>
void TestFunction1() {
  std::string s1{"string"};
  std::string s2{std::move(s1)};
  s2.~basic_string();
  std::cout << s1 << "\n"; // NON_COMPLIANT
}

void TestFunction2() {
  std::unique_ptr<int> ptr1 = std::make_unique<int>(0);
  // unique_ptr move constructor
  std::unique_ptr<int> ptr2{std::move(ptr1)};
  std::cout << *ptr1.get() << std::endl; // COMPLIANT
}

void TestSafeFunctions() {
  std::shared_ptr<int> ptr1 = std::make_shared<int>(0);
  // shared_ptr move constructor
  std::shared_ptr<int> ptr2{std::move(ptr1)};
  std::cout << *ptr1.get() << std::endl; // COMPLIANT
}

void print(std::string v) { std::cout << v << std::endl; }
void f() {
  std::string s{"string"};
  for (unsigned i = 0; i < 10; ++i) {
    s.append("another string"); // NON_COMPLIANT
    print(std::move(s));        // NON_COMPLIANT
  }
}

void f_compliant() {
  for (unsigned i = 0; i < 10; ++i) {
    std::string s("new string"); // COMPLIANT
    print(std::move(s));
  }
}

void f_compliant2() {
  for (unsigned i = 0; i < 10; ++i) {
    std::string s_new("new string"); // COMPLIANT
    print(s_new);                    // COMPLIANT
    print(std::move(s_new));
  }
}

void test_reassign() {
  int x, y;
  int tmp(std::move(x));
  x = std::move(y);   // COMPLIANT
  y = std::move(tmp); // COMPLIANT
}

void test_reassign_overloaded() {
  std::string x("x"), y("y");
  std::string tmp(std::move(x));
  x = std::move(y);   // COMPLIANT
  y = std::move(tmp); // COMPLIANT
}

// moved-from member variable
class TestMovedMember {
public:
  std::string s_member{"string"};
};
void test_moved_member() {
  TestMovedMember m;
  std::string s2{std::move(m.s_member)};
  std::cout << m.s_member << "\n"; // NON_COMPLIANT[FALSE_NEGATIVE]
}

// moved-from global variable
std::string s_global{"string"};
void test_moved_global() {
  std::string s2{std::move(s_global)};
  std::cout << s_global << "\n"; // NON_COMPLIANT
}
