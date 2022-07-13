#define NOOP

typedef int *p;                   // COMPLIANT
typedef int *p1, *p2;             // NON_COMPLIANT
typedef int *p3, p4;              // NON_COMPLIANT
constexpr p4 const *p5 = nullptr; // COMPLIANT

void f1() {
  int a = 0;           // COMPLIANT
  int b, *c = nullptr; // NON_COMPLIANT
  int d, e = 0;        // NON_COMPLIANT
}

struct S1 {
  int S1_a;
  int S1_b;
  int S1_c;
};

void f2() {
  for (int i = 0, j = 0; i < 10; i++) {
    j++; // COMPLIANT
  }      // COMPLIANT - as exception

  for (int i = 0, j = 0; i < 10; i++, j++) {
  } // COMPLIANT - because of i++, j++ is not an expression statement

  for (int i = 0, j = 0; i < 10; i = i + 1, j = j + 1) {

  } // COMPLIANT - because of i+1, j+1 is not a expression statement

  // clang-format off
  for(int i=0, j=0; i < 10; ({i = i+1; j = j+1;})){
    // clang-format on

  } // NON_COMPLIANT - because ({i = i+1, j = j+1}) is an expression statement

  int i = 0;

  // clang-format off
  while(({i=i+1; i=i+1;}) && i < 10){
    // clang-format on
    i++;
  } // NON_COMPLIANT - because ({i=i+1; i=i+1;}) is an expression statement

  f1(); // COMPLIANT

  // clang-format off
  f1(); f1(); // NON_COMPLIANT
  // clang-format on
}

int f3() {
  // clang-format off
  int a{10}; int b{2600}; // NON_COMPLIANT
  // clang-format on

  int c{10};   // COMPLIANT
  int d{2600}; // COMPLIANT

  // clang-format off
  c++; d++; // NON_COMPLIANT
  d++; ++c; // NON_COMPLIANT
  d++; f1(); // NON_COMPLIANT
  int e; e++; // NON_COMPLIANT 
  d++; int g; // NON_COMPLIANT

  // clang-format on
  return ++c;
}

void f4() {
  struct S2 {
    int S2_a;
    int S2_b;
    int S2_c;
  };
}

struct S3 {
  // clang-format off
  int S3_a; int S3_b; // NON_COMPLIANT
  // clang-format on
};

static S3 S3s[] = {{1, 2}, {3, 4}}; // COMPLIANT

void f5() {

  int a[100]; // COMPLIANT

  for (auto i : a) {
    NOOP;
  } // COMPLIANT

  for (const auto &it : S3s) {
    NOOP;
  } // COMPLIANT

  for (auto it : S3s) {
    NOOP;
  } // COMPLIANT

  for (const auto it : S3s) {
    NOOP;
  } // COMPLIANT
}

template <typename K, typename V> inline K aif(K k, V v) {
  if (k == 'c') {
    return k * 10;
  }
  return k;
} // COMPLIANT

void f6() {
  aif('c', 10); // COMPLIANT
}

template <typename K, typename V> class C1 {
public:
  class C2 {
  public:
    C2 c(K k, V v);
    int add(int a, int b);
  };
};

template <typename K, typename V> inline int C1<K, V>::C2::add(int a, int b) {
  return 0;
} // COMPLIANT

////
template <typename K, typename V>
typename C1<K, V>::C2 C1<K, V>::C2::c(K a, V b) {
  C1<K, V>::C2 cc;
  return cc;
} // COMPLIANT

#include <memory>
#include <thread>
struct s_357 {
  void run() { return; }
  void test_357() {
    // clang-format off
    std::unique_ptr<std::thread> _thread = std::make_unique<std::thread>([this]() { run(); }); // COMPLIANT
    // clang-format on
  }
};
