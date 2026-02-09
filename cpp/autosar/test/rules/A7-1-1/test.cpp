#include <iostream>
#include <string>

void f1(int *p) { // COMPLIANT
  *p += 2;
}
void f2(int *p) { // COMPLIANT - we ignore parameters for this rule
  int l4 = 1;     // NON_COMPLIANT
  int *p1 = p;    // NON_COMPLIANT
}

void initl6(char *l) { l = {0}; }

void f() {
  const int l = 1;      // COMPLIANT
  constexpr int l1 = 1; // COMPLIANT
  int l2 = 1;           // NON_COMPLIANT

  int l3 = 1; // COMPLIANT
  f1(&l3);

  int l4 = 1; // COMPLIANT
  f2(&l4);

  const int l5[] = {1}; // COMPLIANT

  char l6[4]; // COMPLIANT
  initl6(l6);

  int l7[] = {1}; // NON_COMPLIANT
}

class A7_1_1a final {
public:
  struct A {
    std::string m;
  };
  void Set(const A &a) { // COMPLIANT
    m_ = a.m;
  }
  void Call() {
    // ignore lambdas
    [this]() { std::cout << m_ << '\n'; }(); // COMPLIANT
  }

private:
  std::string m_;
};

template <typename T> class A7_1_1b final {
public:
  explicit A7_1_1b(int i) noexcept {
    t_.Init(i);
  } // t_ is modified here by Init
private:
  // ignore uninstantiated templates
  T t_; // COMPLIANT
};

class A7_1_1bHelper {
public:
  void Init(int i) {}
};

class Issue18 {
public:
  template <typename T> void F(const T &s) {
    // ignore uninstantiated templates
    std::cout << s << '\n'; // COMPLIANT
    return;
  }
};

/// main
int main(int, char **) noexcept {
  new A7_1_1b<A7_1_1bHelper>(0);

  (new Issue18)->F(0);
}

template <bool... Args> extern constexpr bool recurse_var = true; // COMPLIANT

template <bool B1, bool... Args>
extern constexpr bool recurse_var<B1, Args...> = B1 &&recurse_var<Args...>;

void fp_621() { recurse_var<true, true, true>; }

#include <utility>

void variadic_forwarding() {}

template <typename T, typename... Args>
void variadic_forwarding(T &&first, Args &&...rest) {
  first;
  variadic_forwarding(std::forward<Args>(rest)...);
}

int test_variadic_forwarding() { variadic_forwarding(1, 1.1, "a"); }
