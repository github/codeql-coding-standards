#include <array>
#include <vector>
void test_checks(std::vector<int> v) {
  if (v.size() > 3) {
    v[0]; // COMPLIANT
    v[1]; // COMPLIANT
    v[2]; // COMPLIANT
    v[3]; // COMPLIANT
    v[4]; // NON_COMPLIANT
  } else {
    v[0]; // NON_COMPLIANT
  }

  if (v.size()) {
    v[0]; // COMPLIANT
    v[1]; // NON_COMPLIANT
  } else {
    v[0]; // NON_COMPLIANT
  }

  if (v.empty()) {
    v[0]; // NON_COMPLIANT
    v[1]; // NON_COMPLIANT
  } else {
    v[0]; // COMPLIANT
    v[1]; // NON_COMPLIANT
  }

  if (v.size() == 3) {
    v[0]; // COMPLIANT
    v[1]; // COMPLIANT
    v[2]; // COMPLIANT
    v[3]; // NON_COMPLIANT
    v[4]; // NON_COMPLIANT
  } else {
    v[0]; // NON_COMPLIANT
  }

  if (v.size() != 0) {
    v[0]; // COMPLIANT
    v[1]; // NON_COMPLIANT
  } else {
    v[0]; // NON_COMPLIANT
  }
}

void test_loops(std::vector<int> v) {
  /*
   * In this case the `i` is signed, but `v.size()` returns `size_t` which is
   * unsigned. If `v.size()` returns a value larger than `int`, then
   *  - `i` may overflow to a negative value.
   *  - the `i < v.size()` comparison will, however, still be valid, because the
   * `i` access will be converted to an unsigned integer first (as comparisons
   * between signed/unsigned happen on the unsigned conversion). The range check
   * is therefore still valid.
   *  - the `v[i]` is also still valid, because [] takes a `size_t` as well, so
   * even if `i` is negative it will get converted to a unsigned, large positive
   * value.
   */
  for (int i = 0; i < v.size(); i++) { // comparison here converts i to unsigned
    v[i]; // COMPLIANT - `i` could be negative, but gets converted to unsigned
  }

  for (size_t i = 0; i < v.size(); i++) {
    v[i]; // COMPLIANT
  }
}

void test_init_resize() {
  std::vector<int> v(3, 0);

  v[0]; // COMPLIANT
  v[1]; // COMPLIANT
  v[2]; // COMPLIANT
  v[3]; // NON_COMPLIANT

  v.resize(1, 0);
  v[0]; // COMPLIANT
  // This is a false negative because we consider the maximum of all possible
  // prior size indicators including the original size
  v[1]; // NON_COMPLIANT[FALSE_NEGATIVE]

  v.resize(4, 0);
  v[0]; // COMPLIANT
  v[1]; // COMPLIANT
  v[2]; // COMPLIANT
  v[3]; // COMPLIANT
  v[4]; // NON_COMPLIANT
}

void test_initializer_list() {
  std::vector<int> v{1, 2, 3};

  v[0]; // COMPLIANT
  v[1]; // COMPLIANT
  v[2]; // COMPLIANT
  v[3]; // NON_COMPLIANT
}

void test_std_array(std::array<int, 3> a) {
  a[0]; // COMPLIANT
  a[1]; // COMPLIANT
  a[2]; // COMPLIANT
  a[3]; // NON_COMPLIANT
}

std::vector<int> gv;

void test_global() {
  if (gv.size() > 3) {
    gv[0]; // COMPLIANT
    gv[1]; // COMPLIANT
    gv[2]; // COMPLIANT
    gv[3]; // COMPLIANT
    gv[4]; // NON_COMPLIANT
  } else {
    gv[0]; // NON_COMPLIANT
  }
}

class ClassA {
public:
  std::vector<int> mv;
  std::vector<int> mv2[2];
};

void test_members(ClassA *a) {
  if (a->mv.size() > 3) {
    a->mv[0]; // COMPLIANT
    a->mv[1]; // COMPLIANT
    a->mv[2]; // COMPLIANT
    a->mv[3]; // COMPLIANT
    a->mv[4]; // NON_COMPLIANT
  } else {
    a->mv[0]; // NON_COMPLIANT
  }

  if (a->mv2[0].size() > 3) {
    a->mv2[0][0]; // COMPLIANT
    a->mv2[0][1]; // COMPLIANT
    a->mv2[0][2]; // COMPLIANT
    a->mv2[0][3]; // COMPLIANT
    a->mv2[0][4]; // NON_COMPLIANT
  } else {
    a->mv2[0][0]; // NON_COMPLIANT
  }
}