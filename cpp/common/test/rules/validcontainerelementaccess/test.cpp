#include <string>
#include <vector>

void f1(const int *ar) {
  std::vector<int> d;
  auto it = d.begin();
  for (auto i = 0; i < 2; ++i, ++it) { // NON_COMPLIANT - Some iterations may
                                       // result in invalid access to container.
    d.insert(it, ar[i]); // NON_COMPLIANT - Some iterations may result in
                         // invalid access to container.
  }
}

void f2(const int *ar) {
  std::vector<int> d;
  auto it = d.begin();
  for (auto i = 0; i < 2; ++i, ++it) {
    it = d.insert(
        it, ar[i]); // COMPLIANT - `it` is reestablished prior to next access.
  }
}

void f3(const int *ar) {
  std::vector<int> d;
  auto it = d.begin();
  for (auto i = 0; i < 2;
       ++i, ++it) { // COMPLIANT - `it` is always re-established.

    int *dd = &*d.begin();
    it = d.insert(
        it, ar[i]); // COMPLIANT - `it` is reestablished prior to next access.
    *dd = 10;       // NON_COMPLIANT - `dd` may be invalid although `it` was
                    // reestablished.
  }
}

void f4(const int *ar) {
  std::vector<int> d;
  auto it = d.begin();
  for (auto i = 0; i < 2;
       ++i, ++it) { // COMPLIANT - `it` is always re-established.

    int *dd = &*d.begin();

    it = d.insert(
        it, ar[i]); // COMPLIANT - `it` is reestablished prior to next access.

    dd = &*d.begin();

    *dd = 10; // COMPLIANT - `dd` is refreshed after the destructive call.
  }
}

void f5(const int *ar) {
  std::vector<int> d;
  auto it = d.begin();

  d.clear();

  it = d.insert(it, ar[0]); // NON_COMPLIANT - `it` may be invalid
}

void f6(const int *ar) {
  std::vector<int> d;
  auto it = d.begin();

  d.clear();

  it = d.begin();

  it = d.insert(it, ar[0]); // COMPLIANT - `it` is reestablished.
}

void f7(const int *ar) {
  std::vector<int> d;
  auto it = d.begin();
  for (auto i = 0; i < 2;
       ++i, ++it) { // NON_COMPLIANT - `it` may be invalid on some iterations.
    it = d.insert(
        it, ar[i]); // NON_COMPLIANT - `it` may be invalid on some iterations.
    d.clear();
  }
}

void f8(const int *ar) {
  std::vector<int> d;
  auto it = d.begin();
  for (auto i = 0; i < 2;
       ++i, ++it) { // NON_COMPLIANT - `it` may be invalid on some iterations.
    it = d.insert(
        it, ar[i]); // NON_COMPLIANT - `it` may be invalid on some iterations.
    d.insert(it, ar[i]); // COMPLIANT - `it` is always reestablished.
  }
}

void f9(const std::string &s, std::string &str) {
  std::string::iterator loc = str.begin();
  for (auto i = s.begin(), e = s.end(); i != e; ++i, ++loc) { // NON_COMPLIANT
    str.insert(loc, 'c');                                     // NON_COMPLIANT
  }
}

void f10(const std::string &s, std::string &str) {
  std::string::iterator loc = str.begin();
  for (auto i = s.begin(), e = s.end(); i != e; ++i, ++loc) { // COMPLIANT
    loc = str.insert(loc, 'c');                               // COMPLIANT
  }
}

void f11(std::string cs) {
  const char *cp = cs.c_str();
  const char *cpe = cp + 2;

  while (cp < cpe) {     // COMPLIANT
    std::string arg(cp); // COMPLIANT
    cp += arg.size() + 1;
  }
}