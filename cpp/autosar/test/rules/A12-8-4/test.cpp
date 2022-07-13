#include <string>
#include <utility>

// Some projects have their own move wrappers
template <typename T> constexpr T &&mymove(T &t) noexcept {
  return static_cast<T &&>(t);
}

class MyCustomClass { // Includes compiler generated move constructor, which
                      // inits m_s1
private:
  std::string m_s1;
};

class MyCustomClass2 { // Includes compiler generated move constructor
};

class ClassA {
public:
  ClassA(ClassA &&other)
      : m_i1(std::move(other.m_i1)),     // COMPLIANT
        m_i2(other.m_i2),                // COMPLIANT
        m_s1(std::move(other.m_s1)),     // COMPLIANT
        m_s2(mymove(other.m_s2)),        // COMPLIANT
        m_s3(other.m_s3),                // NON_COMPLIANT - copy, not move!
        m_c1(std::move(other.m_c1)),     // COMPLIANT
        m_c2(mymove(other.m_c2)),        // COMPLIANT
        m_c3(other.m_c3),                // NON_COMPLIANT - copy, not move!
        m_c2_1(std::move(other.m_c2_1)), // COMPLIANT
        m_c2_2(mymove(other.m_c2_2)),    // COMPLIANT
        m_c2_3(other.m_c2_3)             // NON_COMPLIANT - copy, not move!
  {}

private:
  int m_i1;
  int m_i2;
  std::string m_s1;
  std::string m_s2;
  std::string m_s3;
  MyCustomClass m_c1;
  MyCustomClass m_c2;
  MyCustomClass m_c3;
  MyCustomClass2 m_c2_1;
  MyCustomClass2 m_c2_2;
  MyCustomClass2 m_c2_3;
};