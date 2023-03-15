#include <mutex>

struct Foo {
  int m_i1;
  int m_i2;
  struct {
    int m_s1_i1;
    int m_s1_i2;
  } m_s1;
};

struct Bar {
  struct {
    int m_s1_i1;
    int m_s1_i2;
  } m_s1;
  int m_i1;
  int m_i2;
};

struct Baz {
  int m_baz_i1;
  int m_baz_i2;
  std::mutex m_mutex;
  Foo f;
};

class StructNested {
public:
  int m_nested_i1;
  int *m_nested_i2;
  Baz m_baz;
  int m_array[10];
  StructNested() = default;
  ~StructNested();
};

void test() {
  int l1[4]{1, 2, 3, 4};                        // COMPLIANT
  int l2[4][2]{{1, 2}, {3, 4}, {3, 4}, {3, 4}}; // COMPLIANT
  int l3[4][2]{1, 2, 3, 4, 3, 4, 3, 4}; // NON_COMPLIANT - implied braces
  int l4[4][2]{0};                      // COMPLIANT
  int l5[4][2]{{}, {}, {}, {}};     // NON_COMPLIANT - nested zero initializer
  int l6[4][2]{{0}, {0}, {0}, {0}}; // NON_COMPLIANT - nested zero initializer
  int l7[4][2]{};                   // COMPLIANT
  int l8[4]{1, 2};                  // NON_COMPLIANT - missing explicit init
  int l9[4][2]{{1, 2}};             // NON_COMPLIANT - missing explicit init
  Foo f{1, 2, 3, 4};                // NON_COMPLIANT - implied braces
  Foo f1{1, 2, {3, 4}};             // COMPLIANT
  Foo f3{};                         // COMPLIANT
  Foo f4{0, 2};                     // NON_COMPLIANT - missing explicit init
  Foo f5{0, 2, {}};                 // NON_COMPLIANT - nested zero initializer
  Bar b{};                          // COMPLIANT
  Bar b1{0};                        // COMPLIANT
  Bar b2{{0}};      // NON_COMPLIANT - missing explicit init, nested zero init
  StructNested n{}; // COMPLIANT
  StructNested n1 = {}; // COMPLIANT
}