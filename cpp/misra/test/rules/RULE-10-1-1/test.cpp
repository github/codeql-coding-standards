#include <cstdint>
#include <vector>

void f1(std::int8_t *p1,       // NON_COMPLIANT - *p1 not modified
        const std::int8_t *p2, // COMPLIANT - already const
        std::int8_t *p3,       // COMPLIANT - *p3 modified
        std::int8_t *const p4, // NON_COMPLIANT - *p4 not modified
        std::int8_t p5[3]) {   // NON_COMPLIANT - array decays to pointer
  *p3 = *p1 + *p2 + *p4 + p5[2];
}

void f2(std::int32_t &l1,  // COMPLIANT - modified
        std::int32_t &&l2, // COMPLIANT - rvalue reference, rule N/A
        std::int32_t &) {  // COMPLIANT - unnamed, rule N/A
  l1 = 0;
}

auto f3(std::vector<std::int32_t> &l1, // COMPLIANT - x.begin() is non-const
        std::vector<std::int32_t> &l2  // NON_COMPLIANT - cbegin is const
) {
  l1.begin();
  l2.cbegin();
}

int32_t i32;
int32_t *ptr;
const int32_t *cptr;
int32_t &ref = i32;
void take_i32(std::int32_t l1);
void take_ptr(std::int32_t *l1);
void take_cptr(const std::int32_t *l1);
void take_cptrc(const std::int32_t *const l1);
void take_ptrc(std::int32_t *const l1);
void take_ref(std::int32_t &l1);
void take_cref(const std::int32_t &l1);

void f4() {
  // Pointers used as values
  [](std::int32_t *p1) { *p1 = 0; };             // COMPLIANT
  [](std::int32_t *p1) { p1 = nullptr; };        // NON_COMPLIANT
  [](std::int32_t *p1) { i32 = *p1; };           // NON_COMPLIANT
  [](std::int32_t *p1) { take_i32(*p1); };       // NON_COMPLIANT
  [](std::int32_t *p1) { ref = *p1; };           // COMPLIANT
  [](std::int32_t *p1) { take_ref(*p1); };       // COMPLIANT
  [](std::int32_t *p1) { const int &l1 = *p1; }; // NON_COMPLIANT
  [](std::int32_t *p1) { take_cref(*p1); };      // NON_COMPLIANT

  // References used as values
  [](std::int32_t &p1) { p1 = 0; };             // COMPLIANT
  [](std::int32_t &p1) { i32 = p1; };           // NON_COMPLIANT
  [](std::int32_t &p1) { take_i32(p1); };       // NON_COMPLIANT
  [](std::int32_t &p1) { ref = p1; };           // COMPLIANT
  [](std::int32_t &p1) { take_ref(p1); };       // COMPLIANT
  [](std::int32_t &p1) { const int &l1 = p1; }; // NON_COMPLIANT
  [](std::int32_t &p1) { take_cref(p1); };      // NON_COMPLIANT

  // Pointers used as pointers
  [](std::int32_t *p1) { ptr = p1; };                          // COMPLIANT
  [](std::int32_t *p1) { take_ptr(p1); };                      // COMPLIANT
  [](std::int32_t *p1) { cptr = p1; };                         // NON_COMPLIANT
  [](std::int32_t *p1) { take_cptr(p1); };                     // NON_COMPLIANT
  [](std::int32_t *p1) { const std::int32_t *const l1 = p1; }; // NON_COMPLIANT
  [](std::int32_t *p1) { take_cptrc(p1); };                    // NON_COMPLIANT
  [](std::int32_t *p1) { std::int32_t *const l1 = p1; };       // COMPLIANT
  [](std::int32_t *p1) { take_ptrc(p1); };                     // COMPLIANT

  // Taking addresses of references parameter
  [](std::int32_t &p1) { ptr = &p1; };                          // COMPLIANT
  [](std::int32_t &p1) { take_ptr(&p1); };                      // COMPLIANT
  [](std::int32_t &p1) { cptr = &p1; };                         // NON_COMPLIANT
  [](std::int32_t &p1) { take_cptr(&p1); };                     // NON_COMPLIANT
  [](std::int32_t &p1) { const std::int32_t *const l1 = &p1; }; // NON_COMPLIANT
  [](std::int32_t &p1) { take_cptrc(&p1); };                    // NON_COMPLIANT
  [](std::int32_t &p1) { std::int32_t *const l1 = &p1; };       // COMPLIANT
  [](std::int32_t &p1) { take_ptrc(&p1); };                     // COMPLIANT

  // Returning from pointer parameters
  [](std::int32_t *p1) -> std::int32_t { return *p1; };         // NON_COMPLIANT
  [](std::int32_t *p1) -> std::int32_t & { return *p1; };       // COMPLIANT
  [](std::int32_t *p1) -> const std::int32_t & { return *p1; }; // NON_COMPLIANT
  [](std::int32_t *p1) -> std::int32_t * { return p1; };        // COMPLIANT
  [](std::int32_t *p1) -> const std::int32_t * { return p1; };  // NON_COMPLIANT
  [](std::int32_t *p1) -> std::int32_t *const { return p1; };  // COMPLIANT
  [](std::int32_t *p1) -> const std::int32_t *const {
    return p1;
  }; // NON_COMPLIANT

  // Returning from reference parameters
  [](std::int32_t &p1) -> std::int32_t { return p1; };          // NON_COMPLIANT
  [](std::int32_t &p1) -> std::int32_t & { return p1; };        // COMPLIANT
  [](std::int32_t &p1) -> const std::int32_t & { return p1; };  // NON_COMPLIANT
  [](std::int32_t &p1) -> std::int32_t * { return &p1; };       // COMPLIANT
  [](std::int32_t &p1) -> const std::int32_t * { return &p1; }; // NON_COMPLIANT
  [](std::int32_t &p1) -> std::int32_t *const { return &p1; }; // COMPLIANT
  [](std::int32_t &p1) -> const std::int32_t *const {
    return &p1;
  }; // NON_COMPLIANT

  // Returning from reference parameters
  [](std::int32_t &p1) -> std::int32_t { return p1; };          // NON_COMPLIANT
  [](std::int32_t &p1) -> std::int32_t & { return p1; };        // COMPLIANT
  [](std::int32_t &p1) -> const std::int32_t & { return p1; };  // NON_COMPLIANT
  [](std::int32_t &p1) -> std::int32_t * { return &p1; };       // COMPLIANT
  [](std::int32_t &p1) -> const std::int32_t * { return &p1; }; // NON_COMPLIANT
  [](std::int32_t &p1) -> std::int32_t *const { return &p1; }; // COMPLIANT
  [](std::int32_t &p1) -> const std::int32_t *const {
    return &p1;
  }; // NON_COMPLIANT

  // Non compliant cases are compliant when const
  using cpi32 = const std::int32_t *;
  using cri32 = const std::int32_t &;
  [](const std::int32_t *p1) { p1 = nullptr; };               // COMPLIANT
  [](const std::int32_t *p1) { i32 = *p1; };                  // COMPLIANT
  [](const std::int32_t *p1) { take_i32(*p1); };              // COMPLIANT
  [](const std::int32_t *p1) { const int &l1 = *p1; };        // COMPLIANT
  [](const std::int32_t *p1) { take_cref(*p1); };             // COMPLIANT
  [](const std::int32_t &p1) { i32 = p1; };                   // COMPLIANT
  [](const std::int32_t &p1) { take_i32(p1); };               // COMPLIANT
  [](const std::int32_t &p1) { const int &l1 = p1; };         // COMPLIANT
  [](const std::int32_t &p1) { take_cref(p1); };              // COMPLIANT
  [](const std::int32_t *p1) { cptr = p1; };                  // COMPLIANT
  [](const std::int32_t *p1) { take_cptr(p1); };              // COMPLIANT
  [](cpi32 p1) { const std::int32_t *const l1 = p1; };        // COMPLIANT
  [](cpi32 p1) { take_cptrc(p1); };                           // COMPLIANT
  [](cri32 p1) { cptr = &p1; };                               // COMPLIANT
  [](cri32 p1) { take_cptr(&p1); };                           // COMPLIANT
  [](cri32 p1) { const std::int32_t *const l1 = &p1; };       // COMPLIANT
  [](cri32 p1) { take_cptrc(&p1); };                          // COMPLIANT
  [](cpi32 p1) -> std::int32_t { return *p1; };               // COMPLIANT
  [](cpi32 p1) -> const std::int32_t & { return *p1; };       // COMPLIANT
  [](cpi32 p1) -> const std::int32_t * { return p1; };        // COMPLIANT
  [](cpi32 p1) -> const std::int32_t *const { return p1; };  // COMPLIANT
  [](cri32 p1) -> std::int32_t { return p1; };                // COMPLIANT
  [](cri32 p1) -> const std::int32_t & { return p1; };        // COMPLIANT
  [](cri32 p1) -> const std::int32_t * { return &p1; };       // COMPLIANT
  [](cri32 p1) -> const std::int32_t *const { return &p1; }; // COMPLIANT

  // Non pointer compliant cases are not compliant for `int32_t *const`.
  using pi32c = std::int32_t *const;

  [](std::int32_t *const p1) { i32 = *p1; };                 // NON_COMPLIANT
  [](std::int32_t *const p1) { take_i32(*p1); };             // NON_COMPLIANT
  [](std::int32_t *const p1) { const int &l1 = *p1; };       // NON_COMPLIANT
  [](std::int32_t *const p1) { take_cref(*p1); };            // NON_COMPLIANT
  [](std::int32_t *const p1) { cptr = p1; };                 // NON_COMPLIANT
  [](std::int32_t *const p1) { take_cptr(p1); };             // NON_COMPLIANT
  [](pi32c p1) { const std::int32_t *const l1 = p1; };       // NON_COMPLIANT
  [](pi32c p1) { take_cptrc(p1); };                          // NON_COMPLIANT
  [](pi32c p1) -> std::int32_t { return *p1; };              // NON_COMPLIANT
  [](pi32c p1) -> const std::int32_t & { return *p1; };      // NON_COMPLIANT
  [](pi32c p1) -> const std::int32_t * { return p1; };       // NON_COMPLIANT
  [](pi32c p1) -> const std::int32_t *const { return p1; }; // NON_COMPLIANT
}

void f5(std::int32_t *p1,       // NON_COMPLIANT -- pointer modified
        std::int32_t *p2,       // COMPLIANT -- pointee modified
        std::int32_t &p3,       // COMPLIANT -- reference modified
        std::int32_t *p4,       // NON_COMPLIANT -- pointer assigned
        std::int32_t *p5,       // COMPLIANT -- pointee assigned
        std::int32_t &p6,       // COMPLIANT -- assigned
        const std::int32_t *p7, // COMPLIANT
        const std::int32_t &p8, // COMPLIANT
        std::int32_t *p9,       // NON_COMPLIANT
        std::int32_t &p10,      // NON_COMPLIANT
        std::int32_t *p11,      // COMPLIANT
        std::int32_t *p12,      // NON_COMPLIANT -- unused
        std::int32_t **p13,     // COMPLIANT
        std::int32_t **p14,     // COMPLIANT
        std::int32_t **p15,     // COMPLIANT
        std::int32_t **p16      // COMPLIANT
) {
  p1++;
  (*p2)++;
  p3++;
  p4 += 0;
  *p5 *= 0;
  p6 /= 0;
  p7++;
  if (p8) {
  }
  p9 ? true : false;
  while (p10) {
  }
  p11[0] = 0;
  // p12
  p13[0] = p1;
  p14[0][0] = 0;
  (*p15)[0] = 0;
  *(p16[0]) = 0;
}

struct S {
  std::int32_t m1;
};

void f6(S *p1, // COMPLIANT
        S *p2, // NON_COMPLIANT
        S *p3  // COMPLIANT
) {
  p1->m1 = 1;
  std::int32_t l1 = p2->m1;
  std::int32_t &l2 = p3->m1;
}

void f7(std::int32_t *p1, // COMPLIANT
        std::int32_t *p2, // COMPLIANT
        std::int32_t *p3, // NON_COMPLIANT[False negative]
        std::int32_t *p4  // NON_COMPLIANT
) {
  using pi32 = std::int32_t *;
  using cpi32 = const std::int32_t *;
  using ci32 = const std::int32_t;

  pi32 *l1 = &p1;       // pointer to pointer to non-const
  pi32 &l2 = p2;        // reference to pointer to non-const
  cpi32 *l3 = &p3;      // pointer to pointer to const
  const cpi32 &l4 = p4; // (const) reference to pointer to const
  // cpi32 &l4 = p4; -- does not compile, non-const lvalues cannot involve a
  // const cast from *i32 to const i32*
}

int main(int argc, char *argv[]);            // COMPLIANT - main is excluded
void f8(std::int32_t *p1, std::int32_t &p2); // COMPLIANT - no body to analyze
void f9(std::int32_t *p1, std::int32_t &p2) = delete; // COMPLIANT - deleted
void f10(void *l1) {} // COMPLIANT - void pointer excluded

class Base {
public:
  virtual void f(std::int32_t *p1, std::int32_t &p2); // COMPLIANT
};

class Derived : public Base {
public:
  void f(std::int32_t *p1, std::int32_t &p2) override; // COMPLIANT
};

template <typename T> struct A {
  void m1(T &p1, T *p2) {} // COMPLIANT - in template scope

  void m2() {
    auto lambda = [](std::int32_t &l2) {
    }; // COMPLIANT - lambda in template scope
  }
};

template <typename T> void f11(T &l1) {} // COMPLIANT - function template