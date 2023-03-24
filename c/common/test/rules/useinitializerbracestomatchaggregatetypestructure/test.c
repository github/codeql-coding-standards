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
  struct Foo f;
};

struct StructNested {
  int m_nested_i1;
  int *m_nested_i2;
  struct Baz m_baz;
  int m_array[10];
};

void test() {
  int l01[4] = {1, 2, 3, 4};                        // COMPLIANT
  int l02[4][2] = {{1, 2}, {3, 4}, {3, 4}, {3, 4}}; // COMPLIANT
  int l03[4][2] = {1, 2, 3, 4, 3, 4, 3, 4}; // NON_COMPLIANT - implied braces
  int l04[4][2] = {0};                      // COMPLIANT
  int l06[4][2] = {{0}, {0}, {0}, {0}}; // COMPLIANT, nested zero initializer
  int l08[4] = {1, 2};                  // COMPLIANT, but missing explicit init
  int l09[2][2] = {{1, 2}};             // COMPLIANT, but missing explicit init
  int l10[2][2] = {{1, 2}, [1] = {0}};  // COMPLIANT
  int l11[2][2] = {{1, 2}, [1] = 0};    // NON_COMPLIANT - implied braces
  int l12[2][2] = {{1, 2}, [1][0] = 0, [1][1] = 0}; // COMPLIANT
  int l13[2][2] = {{0}, [1][0] = 0};                // COMPLIANT
  int l14[2][2] = {
      {0}, [1][0] = 0, 0}; // NON_COMPLIANT[FALSE_NEGATIVE] - not all elements
                           // initialized with designated initializer
  struct Foo f1 = {1, 2, 3, 4};   // NON_COMPLIANT - implied braces
  struct Foo f2 = {1, 2, {3, 4}}; // COMPLIANT
  struct Foo f3 = {0};            // COMPLIANT
  struct Foo f4 = {0, 2};         // COMPLIANT, but missing explicit init
  struct Foo f5 = {0, 2, {0}};    // COMPLIANT
  struct Bar b1 = {0};            // COMPLIANT
  struct Bar b2 = {{0}};          // COMPLIANT, but missing explicit init
  struct StructNested n = {0};    // COMPLIANT
}