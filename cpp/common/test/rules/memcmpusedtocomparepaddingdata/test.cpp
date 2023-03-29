#include <string>

struct S1 {
  unsigned char buffType;
  int size;

  friend bool operator==(const S1 &lhs, const S1 &rhs) {
    return lhs.buffType == rhs.buffType && lhs.size == rhs.size;
  }
};

struct S2 {
  unsigned char buff[16];
};

void f(const S1 &s1, const S1 &s2) {
  if (s1 == s2) {
    // COMPLIANT S overloads operator==() to perform a comparison of the value
    // representation of the object
  }
}
void f1(const S1 &s1, const S1 &s2) {
  if (!std::memcmp(&s1, &s2, sizeof(S1))) { // NON_COMPLIANT
  }
}

void f2(const S2 &s1, const S2 &s2) {
  if (!std::memcmp(&s1.buff, &s2.buff, sizeof(S2::buff))) { // COMPLIANT
  }
}