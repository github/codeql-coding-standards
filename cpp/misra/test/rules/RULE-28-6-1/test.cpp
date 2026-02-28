#include <string>
#include <utility>

template <typename T> T func(T param);

std::string f2();

void f3() {
  std::string l1{"hello"};
  std::string &l2 = l1;
  std::string const &l3 = l1;
  std::string const l4{"hello"};
  std::string &&l5 = std::string{"hello"};
  const std::string &&l6 = std::string{"hello"};

  func(std::move(l1)); // COMPLIANT - non-const lvalue
  func(std::move(l2)); // COMPLIANT - non-const lvalue
  func(std::move(l3)); // NON_COMPLIANT - const lvalue
  func(std::move(l4)); // NON_COMPLIANT - const lvalue
  func(std::move(l5)); // COMPLIANT - non-const glvalue
  func(std::move(l6)); // NON_COMPLIANT - const lvalue

  func(std::move(std::string("hello"))); // NON_COMPLIANT - rvalue argument
  func(std::move(l1 + "!"));             // NON_COMPLIANT - temporary rvalue
  func(std::move(f2())); // NON_COMPLIANT - rvalue from function call
}

class TestClass {
public:
  std::string m1;
  std::string const m2{"constant"};

  void test_member_variables() {
    std::move(m1); // COMPLIANT - non-const member
    std::move(m2); // NON_COMPLIANT - const member
  }
};

// NON_COMPLIANT -- always moving const value
template <typename T> void cref_tpl1(const T &param) { std::move(param); }
// NON_COMPLIANT -- always moving const value
template <typename T> void cref_tpl2(const T &param) { std::move(param); }
// NON_COMPLIANT -- always moving const value
template <typename T> void cref_tpl3(const T &param) { std::move(param); }
// NON_COMPLIANT -- always moving const value
template <typename T> void cref_tpl4(const T &param) { std::move(param); }
// NON_COMPLIANT -- always moving const value
template <typename T> void cref_tpl5(const T &param) { std::move(param); }
// NON_COMPLIANT -- always moving const value
template <typename T> void cref_tpl6(const T &param) { std::move(param); }

// T=std::string -- COMPLIANT
template <typename T> void ref_tpl1(T &param) { std::move(param); }
// T=const std::string -- NON_COMPLIANT, move const lvalue ref
template <typename T> void ref_tpl2(T &param) { std::move(param); }
// T=std::string& -- COMPLIANT
template <typename T> void ref_tpl3(T &param) { std::move(param); }
// T=const std::string& -- NON_COMPLIANT, move const lvalue ref
template <typename T> void ref_tpl4(T &param) { std::move(param); }
// T=std::string&& -- COMPLIANT
template <typename T> void ref_tpl5(T &param) { std::move(param); }
// T=const std::string&& -- NON_COMPLIANT, move const rvalue ref
template <typename T> void ref_tpl6(T &param) { std::move(param); }

// T=std::string -- COMPLIANT
template <typename T> void val_tpl1(T param) { std::move(param); }
// T=const std::string -- NON_COMPLIANT, move const lvalue
template <typename T> void val_tpl2(T param) { std::move(param); }
// T=std::string& -- COMPLIANT
template <typename T> void val_tpl3(T param) { std::move(param); }
// T=const std::string& -- NON_COMPLIANT -- move const lvalue ref
template <typename T> void val_tpl4(T param) { std::move(param); }
// T=std::string&& -- COMPLIANT
template <typename T> void val_tpl5(T param) { std::move(param); }
// T=const std::string&& -- NON_COMPLIANT -- move const rvalue ref
template <typename T> void val_tpl6(T param) { std::move(param); }

// T=std::string -- COMPLIANT
template <typename T> void univ_ref_tpl1(T &&param) { std::move(param); }
// T=const std::string -- NON_COMPLIANT -- moving const rvalue ref
template <typename T> void univ_ref_tpl2(T &&param) { std::move(param); }
// T=std::string& -- COMPLIANT
template <typename T> void univ_ref_tpl3(T &&param) { std::move(param); }
// T=const std::string& -- NON_COMPLIANT -- moving const lvalue ref
template <typename T> void univ_ref_tpl4(T &&param) { std::move(param); }
// T=std::string&& -- COMPLIANT
template <typename T> void univ_ref_tpl5(T &&param) { std::move(param); }
// T=const std::string&& -- NON_COMPLIANT
template <typename T> void univ_ref_tpl6(T &&param) { std::move(param); }

void f4() {
  std::string l1{"test"};
  const std::string l2{"test"};
  std::string &l3 = l1;
  const std::string &l4 = l1;

  val_tpl1<std::string>(l1);
  val_tpl2<const std::string>(l2);
  val_tpl3<std::string &>(l3);
  val_tpl4<const std::string &>(l4);
  val_tpl5<std::string &&>("");
  val_tpl6<const std::string &&>("");
  ref_tpl1<std::string>(l1);
  ref_tpl2<const std::string>(l2);
  ref_tpl3<std::string &>(l3);
  ref_tpl4<const std::string &>(l4);
  ref_tpl5<std::string &&>(l1);
  ref_tpl6<const std::string &&>(l1);
  cref_tpl1<std::string>(l1);
  cref_tpl2<const std::string>(l2);
  cref_tpl3<std::string &>(l3);
  cref_tpl4<const std::string &>(l4);
  cref_tpl5<std::string &&>(l1);
  cref_tpl6<const std::string &&>(l1);
  univ_ref_tpl1<std::string>("");
  univ_ref_tpl2<const std::string>("");
  univ_ref_tpl3<std::string &>(l3);
  univ_ref_tpl4<const std::string &>(l4);
  univ_ref_tpl5<std::string &&>("");
  univ_ref_tpl6<const std::string &&>("");
}

#include <algorithm>
#include <vector>

void algorithm() {
  std::vector<int> v;
  const std::vector<int>::iterator &it = v.begin();
  std::move(it); // NON_COMPLIANT -- from <utility>
  std::move<const std::vector<int>::iterator &>(
      it, it, std::back_inserter(v)); // COMPLIANT -- from <algorithm>
}