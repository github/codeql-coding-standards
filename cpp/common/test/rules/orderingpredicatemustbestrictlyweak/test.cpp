#include <algorithm>
#include <iostream>
#include <map>
#include <set>
#include <vector>

class A {};

class B {
public:
  int f;

  friend bool operator<(const B &lhs, const B &rhs);
  friend bool operator>(const B &lhs, const B &rhs);
  friend bool operator>=(const B &lhs, const B &rhs);
  friend bool operator<=(const B &lhs, const B &rhs);
};

bool operator<(const B &lhs, const B &rhs) { return lhs.f < rhs.f; }
bool operator>(const B &lhs, const B &rhs) { return lhs.f > rhs.f; }
bool operator>=(const B &lhs, const B &rhs) { return lhs.f >= rhs.f; }
bool operator<=(const B &lhs, const B &rhs) { return lhs.f <= rhs.f; }

class C {
public:
  std::set<int> s0;                           // COMPLIANT
  std::set<int, std::less_equal<int>> s1a;    // NON_COMPLIANT
  std::set<int, std::greater_equal<int>> s1b; // NON_COMPLIANT
  std::set<int, std::less<int>> s1c;          // COMPLIANT
  std::set<int, std::greater<int>> s1d;       // COMPLIANT
};

// Non-Audit Cases
void m1() {
  std::set<int> s0;                           // COMPLIANT
  std::set<int, std::less_equal<int>> s1a;    // NON_COMPLIANT
  std::set<int, std::greater_equal<int>> s1b; // NON_COMPLIANT
  std::set<int, std::less<int>> s1c;          // COMPLIANT
  std::set<int, std::greater<int>> s1d;       // COMPLIANT

  std::multiset<int, std::less_equal<int>> s2a;    // NON_COMPLIANT
  std::multiset<int, std::greater_equal<int>> s2b; // NON_COMPLIANT
  std::multiset<int, std::less<int>> s2c;          // COMPLIANT
  std::multiset<int, std::greater<int>> s2d;       // COMPLIANT

  std::map<int, int, std::less_equal<int>> m1a;    // NON_COMPLIANT
  std::map<int, int, std::greater_equal<int>> m1b; // NON_COMPLIANT
  std::map<int, int, std::less<int>> m1c;          // COMPLIANT
  std::map<int, int, std::greater<int>> m1d;       // COMPLIANT

  std::multimap<int, int, std::less_equal<int>> m2a;    // NON_COMPLIANT
  std::multimap<int, int, std::greater_equal<int>> m2b; // NON_COMPLIANT
  std::multimap<int, int, std::less<int>> m2c;          // COMPLIANT
  std::multimap<int, int, std::greater<int>> m2d;       // COMPLIANT
}

void m2() {
  std::set<A> s1; // NON_COMPLIANT - `A` doesn't provide any ordering predicate
  std::set<A, std::less_equal<A>>
      s2; // NON_COMPLIANT - `less_equal` is not compliant
  std::set<A, std::greater_equal<A>>
      s3; // NON_COMPLIANT - `greater_equal` is not compliant
  std::set<A, std::greater<A>>
      s4; // NON_COMPLIANT - `A` does not provide an implementation of `>`
  std::set<A, std::less<A>>
      s5; // NON_COMPLIANT - `A` does not provide an implementation of '<`
}

void m3() {
  std::set<B, std::greater<B>> s1; // COMPLIANT
  std::set<B, std::less<B>> s2;    // COMPLIANT
}

void m4() {
  std::vector<int> v1;
  std::vector<A> v2;
  std::vector<B> v3;

  std::sort(v1.begin(), v1.end(), std::less<int>());    // COMPLIANT
  std::sort(v1.begin(), v1.end(), std::greater<int>()); // COMPLIANT
  std::sort(v1.begin(), v1.end(),
            std::less_equal<int>()); // NON_COMPLIANT -- not a valid ordering
                                     // predicate
  std::sort(v1.begin(), v1.end(),
            std::greater_equal<int>()); // NON_COMPLIANT -- not a valid ordering
                                        // predicate

  // These cases won't compile
  // std::sort(v2.begin(), v2.end()); // NON_COMPLIANT - no predicate specified
  // std::sort(v2.begin(), v2.end(), std::less<A>()); // NON_COMPLIANT - `A`
  // does not implement operator std::sort(v2.begin(), v2.end(),
  // std::greater<A>()); // NON_COMPLIANT - `A` does not implement operator
  // std::sort(v2.begin(), v2.end(), std::less_equal<A>()); // NON_COMPLIANT -
  // `std::less_equal` is not a valid ordering predicate std::sort(v2.begin(),
  // v2.end(), std::greater_equal<A>()); // NON_COMPLIANT - `std::greater_equal`
  // is not a valid ordering predicate

  std::sort(v3.begin(),
            v3.end()); // COMPLIANT - `B` has specified appropriate operators.
  std::sort(v3.begin(), v3.end(),
            std::less<B>()); // COMPLIANT - `B` implements operator
  std::sort(v3.begin(), v3.end(),
            std::greater<B>()); // COMPLIANT - `B` implements operator

  std::sort(v3.begin(), v3.end(),
            std::less_equal<B>()); // NON_COMPLIANT - `std::less_equal` is not a
                                   // valid ordering predicate
  std::sort(v3.begin(), v3.end(),
            std::greater_equal<B>()); // NON_COMPLIANT - `std::greater_equal` is
                                      // not a valid ordering predicate
}

void m5() {
  std::vector<int> v1;
  std::vector<A> v2;
  std::vector<B> v3;

  std::stable_sort(v1.begin(), v1.end(), std::less<int>());    // COMPLIANT
  std::stable_sort(v1.begin(), v1.end(), std::greater<int>()); // COMPLIANT
  std::stable_sort(v1.begin(), v1.end(),
                   std::less_equal<int>()); // NON_COMPLIANT -- not a valid
                                            // ordering predicate
  std::stable_sort(v1.begin(), v1.end(),
                   std::greater_equal<int>()); // NON_COMPLIANT -- not a valid
                                               // ordering predicate

  std::stable_sort(
      v3.begin(),
      v3.end()); // COMPLIANT - `B` has specified appropriate operators.
  std::stable_sort(v3.begin(), v3.end(),
                   std::less<B>()); // COMPLIANT - `B` implements operator
  std::stable_sort(v3.begin(), v3.end(),
                   std::greater<B>()); // COMPLIANT - `B` implements operator

  std::stable_sort(v3.begin(), v3.end(),
                   std::less_equal<B>()); // NON_COMPLIANT - `std::less_equal`
                                          // is not a valid ordering predicate
  std::stable_sort(
      v3.begin(), v3.end(),
      std::greater_equal<B>()); // NON_COMPLIANT - `std::greater_equal` is not a
                                // valid ordering predicate
}

void m6() {
  std::vector<int> v1;
  std::vector<A> v2;
  std::vector<B> v3;

  std::partial_sort(v1.begin(), v1.begin(), v1.end(),
                    std::less<int>()); // COMPLIANT
  std::partial_sort(v1.begin(), v1.begin(), v1.end(),
                    std::greater<int>()); // COMPLIANT
  std::partial_sort(v1.begin(), v1.begin(), v1.end(),
                    std::less_equal<int>()); // NON_COMPLIANT -- not a valid
                                             // ordering predicate
  std::partial_sort(v1.begin(), v1.begin(), v1.end(),
                    std::greater_equal<int>()); // NON_COMPLIANT -- not a valid
                                                // ordering predicate

  std::partial_sort(
      v3.begin(), v3.begin(),
      v3.end()); // COMPLIANT - `B` has specified appropriate operators.
  std::partial_sort(v3.begin(), v3.begin(), v3.end(),
                    std::less<B>()); // COMPLIANT - `B` implements operator
  std::partial_sort(v3.begin(), v3.begin(), v3.end(),
                    std::greater<B>()); // COMPLIANT - `B` implements operator

  std::partial_sort(v3.begin(), v3.begin(), v3.end(),
                    std::less_equal<B>()); // NON_COMPLIANT - `std::less_equal`
                                           // is not a valid ordering predicate
  std::partial_sort(
      v3.begin(), v3.begin(), v3.end(),
      std::greater_equal<B>()); // NON_COMPLIANT - `std::greater_equal` is not a
                                // valid ordering predicate
}

template <class T> class UnknownUserDefinedComparator {
public:
  bool operator()(const T &lhs, const T &rhs) { return false; }
};

/**
 * @IsStrictlyWeaklyOrdered
 */
template <class T> class UserDefinedComparator {
public:
  bool operator()(const T &lhs, const T &rhs) { return false; }
};
void m7() {
  std::vector<int> v1;
  std::vector<A> v2;

  std::set<int, UnknownUserDefinedComparator<int>>
      s1; // NON_COMPLIANT - Not known to be compliant
  std::set<A, UnknownUserDefinedComparator<A>>
      s2; // NON_COMPLIANT - Not known to be compliant
  std::sort(v1.begin(), v1.end(),
            UnknownUserDefinedComparator<int>()); // NON_COMPLIANT - Not known
                                                  // to be compliant
  std::sort(v2.begin(), v2.end(),
            UnknownUserDefinedComparator<A>()); // NON_COMPLIANT - Not known to
                                                // be compliant
}

void m8() {
  std::vector<int> v1;
  std::vector<A> v2;

  std::set<int, UserDefinedComparator<int>>
      s1; // COMPLIANT - User defines as compliant
  std::set<A, UserDefinedComparator<A>>
      s2; // COMPLIANT - User defines as compliant
  std::sort(
      v1.begin(), v1.end(),
      UserDefinedComparator<int>()); // COMPLIANT - User defines as compliant
  std::sort(
      v2.begin(), v2.end(),
      UserDefinedComparator<A>()); // COMPLIANT - User defines as compliant
}
