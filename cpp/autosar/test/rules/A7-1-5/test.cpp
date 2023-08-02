// exception 1 - a variable initialized with a function call or initializer
// of a non-fundamental type.

// Fundamental assignment
auto a0 = 1;   // NON_COMPLIANT
auto a1 = 2.4; // NON_COMPLIANT
auto a2 = 'c'; // NON_COMPLIANT

int f1() { return 0; }

auto a3 = f1(); // COMPLIANT

auto l1 = [](int a, int b) { return a + b; }; // COMPLIANT

auto l2 = [](int a, int b) -> int {
  int c = a + b;
  return c;
}; // COMPLIANT

auto l3 = [](auto a, auto b) -> int { return 0; }; // COMPLIANT

template <typename L> int f2(L &lambda, int a, int b) {
  return lambda(a, b) * 10;
}

void f3() {
  auto a = 2; // NON_COMPLIANT
  auto b = 3; // NON_COMPLIANT

  auto c = l1(a, b);     // COMPLIANT
  auto d = l2(a, b);     // COMPLIANT
  auto e = f2(l1, a, b); // COMPLIANT
}

class C {};

struct S {
  int s1;
  int s2;
};

void f4() {
  auto a = C{};     // COMPLIANT
  auto b = S{1, 2}; // COMPLIANT
}

auto l4 = [](int a, int b) {
  C c;
  return c;
}; // COMPLIANT

auto f5(int a, int b) -> int { return a + b; } // NON_COMPLIANT[FALSE_NEGATIVE]

template <typename T> auto f6(T a, T b) -> decltype(a + b) {
  return a + b;
} // COMPLIANT

auto f7(int a, int b) { return a + b; } // NON_COMPLIANT

void f8() {
  auto a = C{};      // COMPLIANT
  auto b = S{1, 2};  // COMPLIANT
  auto c = f6(1, 2); // COMPLIANT
}

auto f9(int a, int b) -> decltype(a + b) { return a + b; } // NON_COMPLIANT

template <typename T> auto f10(T a, T b) -> int { return a + b; } // COMPLIANT

#include <condition_variable>
#include <memory>
#include <mutex>
#include <thread>
#include <vector>

template <typename T> class Test_380 {
public:
  std::vector<T> _queue;
  void test_380() {
    auto item = _queue.front(); // COMPLIANT
    auto a = 0;                 // NON_COMPLIANT
  }
  auto f(int a) { return a + 1; } // NON_COMPLIANT
};
template <typename T> class Test_381 {
public:
  bool _running = false;
  std::vector<T> _queue;
  void test_381_1() {
    std::unique_ptr<std::thread> _thread;
    _thread = std::make_unique<std::thread>([this]() {}); // COMPLIANT
  }
  void test_381_2() {
    std::mutex m;
    std::unique_lock<std::mutex> lk(m);
    std::condition_variable _condition;
    _condition.wait(
        lk, [this]() { return !_queue.empty() || !_running; }); // COMPLIANT
  }
};
void instantiate() {
  Test_380<int> t380;
  t380.test_380();
  t380.f(1);
  Test_381<int> t381;
  t381.test_381_1();
  t381.test_381_2();
}

void test_loop() {
  for (const auto a : {8, 9, 10}) {
    a;
  }
}