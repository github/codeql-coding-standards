#include <string>
#include <utility>

class TrivMovable {
  int x;

public:
  TrivMovable() = default;
  TrivMovable(const TrivMovable &) = default;
  TrivMovable(TrivMovable &&) = default;
  TrivMovable &operator=(const TrivMovable &) = default;
  TrivMovable &operator=(TrivMovable &&) = default;
};

void f1();

class NonTrivMovable {
  int x;

public:
  NonTrivMovable() = default;
  NonTrivMovable(const NonTrivMovable &other) {
    f1();
    x = other.x;
  }
  NonTrivMovable(NonTrivMovable &&other) {
    f1();
    x = other.x;
  }
  NonTrivMovable &operator=(const NonTrivMovable &other) {
    f1();
    x = other.x;
    return *this;
  }
  NonTrivMovable &operator=(NonTrivMovable &&other) {
    f1();
    x = other.x;
    return *this;
  }
};

void fstr(std::string param);
void fint(int param);
void fmovable(TrivMovable param);
void fnontriv(NonTrivMovable param);

std::string get_str();
int get_int();
TrivMovable get_triv();
NonTrivMovable get_nontriv();

std::string &get_str_ref();
int &get_int_ref();
TrivMovable &get_triv_ref();
NonTrivMovable &get_nontriv_ref();

const std::string &get_str_cref();
const int &get_int_cref();
const TrivMovable &get_triv_cref();
const NonTrivMovable &get_nontriv_cref();

std::string &&get_str_rref();
int &&get_int_rref();
TrivMovable &&get_triv_rref();
NonTrivMovable &&get_nontriv_rref();

const std::string &&get_str_crref();
const int &&get_int_crref();
const TrivMovable &&get_triv_crref();
const NonTrivMovable &&get_nontriv_crref();

void f2() {
  // non-const lvalues
  std::string l1{"hello"};
  int il1{0};
  TrivMovable tml1{};
  NonTrivMovable ntml1{};

  std::move(l1);    // COMPLIANT
  std::move(il1);   // COMPLIANT
  std::move(tml1);  // COMPLIANT
  std::move(ntml1); // COMPLIANT

  fstr(std::move(l1));        // COMPLIANT
  fint(std::move(il1));       // COMPLIANT
  fmovable(std::move(tml1));  // COMPLIANT
  fnontriv(std::move(ntml1)); // COMPLIANT

  // non-const lvalue references
  std::string &l2 = l1;
  int &il2 = il1;
  TrivMovable &tml2 = tml1;
  NonTrivMovable &ntml2 = ntml1;

  std::move(l2);    // COMPLIANT
  std::move(il2);   // COMPLIANT
  std::move(tml2);  // COMPLIANT
  std::move(ntml2); // COMPLIANT

  fstr(std::move(l2));        // COMPLIANT
  fint(std::move(il2));       // COMPLIANT
  fmovable(std::move(tml2));  // COMPLIANT
  fnontriv(std::move(ntml2)); // COMPLIANT

  // const lvalue refs
  std::string const &l3 = l1;
  int const &il3 = il1;
  TrivMovable const &tml3 = tml1;
  NonTrivMovable const &ntml3 = ntml1;

  std::move(l3);    // NON_COMPLIANT
  std::move(il3);   // NON_COMPLIANT
  std::move(tml3);  // NON_COMPLIANT
  std::move(ntml3); // NON_COMPLIANT

  fstr(std::move(l3));        // NON_COMPLIANT
  fint(std::move(il3));       // NON_COMPLIANT
  fmovable(std::move(tml3));  // NON_COMPLIANT
  fnontriv(std::move(ntml3)); // NON_COMPLIANT

  // const lvalues
  std::string const l4{"hello"};
  int const il4{0};
  TrivMovable const tml4{};
  NonTrivMovable const ntml4{};

  std::move(l4);    // NON_COMPLIANT
  std::move(il4);   // NON_COMPLIANT
  std::move(tml4);  // NON_COMPLIANT
  std::move(ntml4); // NON_COMPLIANT

  // non-const lvalues of rvalue reference type
  std::string &&l5 = std::string{"hello"};
  int &&il5 = int{0};
  TrivMovable &&tml5 = TrivMovable{};
  NonTrivMovable &&ntml5 = NonTrivMovable{};

  std::move(l5);    // COMPLIANT
  std::move(il5);   // COMPLIANT
  std::move(tml5);  // COMPLIANT
  std::move(ntml5); // COMPLIANT

  // const lvalues of rvalue reference type
  const std::string &&l6 = std::string{"hello"};
  const int &&il6 = int{0};
  const TrivMovable &&tml6 = TrivMovable{};
  const NonTrivMovable &&ntml6 = NonTrivMovable{};

  std::move(l6);    // NON_COMPLIANT
  std::move(il6);   // NON_COMPLIANT
  std::move(tml6);  // NON_COMPLIANT
  std::move(ntml6); // NON_COMPLIANT

  // xvalues
  std::move(std::string("hello")); // NON_COMPLIANT
  std::move(int(1));               // NON_COMPLIANT
  std::move(TrivMovable());        // NON_COMPLIANT
  std::move(NonTrivMovable());     // NON_COMPLIANT

  fstr(std::move(std::string("hello"))); // NON_COMPLIANT
  fint(std::move(int(1)));               // NON_COMPLIANT
  fmovable(std::move(TrivMovable()));    // NON_COMPLIANT
  fnontriv(std::move(NonTrivMovable())); // NON_COMPLIANT

  std::move(l1 + "!");      // NON_COMPLIANT
  std::move(il1 + 1);       // NON_COMPLIANT
  std::move(get_str());     // NON_COMPLIANT
  std::move(get_int());     // NON_COMPLIANT
  std::move(get_triv());    // NON_COMPLIANT
  std::move(get_nontriv()); // NON_COMPLIANT

  // Function calls returning references
  std::move(get_str_ref());     // COMPLIANT
  std::move(get_int_ref());     // COMPLIANT
  std::move(get_triv_ref());    // COMPLIANT
  std::move(get_nontriv_ref()); // COMPLIANT

  // Function calls returning const references
  std::move(get_str_cref());     // NON_COMPLIANT
  std::move(get_int_cref());     // NON_COMPLIANT
  std::move(get_triv_cref());    // NON_COMPLIANT
  std::move(get_nontriv_cref()); // NON_COMPLIANT

  // Function calls returning rvalue references
  std::move(get_str_rref());     // NON_COMPLIANT
  std::move(get_int_rref());     // NON_COMPLIANT
  std::move(get_triv_rref());    // NON_COMPLIANT
  std::move(get_nontriv_rref()); // NON_COMPLIANT

  std::move(get_str_crref());     // NON_COMPLIANT
  std::move(get_int_crref());     // NON_COMPLIANT
  std::move(get_triv_crref());    // NON_COMPLIANT
  std::move(get_nontriv_crref()); // NON_COMPLIANT
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

// Moving values that are always const:
// NON_COMPLIANT
template <typename T> void cref_tpl1(const T &param) { std::move(param); }
// NON_COMPLIANT
template <typename T> void cref_tpl2(const T &param) { std::move(param); }
// This is actually compliant, because the provided type `T` is a reference and
// the references collapse in a way that drops the const qualifier.
// COMPLIANT
template <typename T> void cref_tpl3(const T &param) { std::move(param); }
// NON_COMPLIANT
template <typename T> void cref_tpl4(const T &param) { std::move(param); }
// This is actually compliant, because the provided type `T` is a reference and
// the references collapse in a way that drops the const qualifier.
// COMPLIANT
template <typename T> void cref_tpl5(const T &param) { std::move(param); }
// NON_COMPLIANT
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

void f3() {
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