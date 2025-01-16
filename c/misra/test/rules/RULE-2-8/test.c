// Not a definition, only a declaration:
extern int g1; // COMPLIANT

// Both declared + defined:
extern int g2; // COMPLIANT
int g2 = 1;    // NON_COMPLIANT

// Definition is only declaration:
int g3 = 1; // NON_COMPLIANT

// Definition, but value is required for program to compile:
int g4 = 1; // COMPLIANT
void f1() { g4; }

// Local variables:
void f2() {
  int l1; // COMPLIANT
  l1;

  int l2; // NON-COMPLIANT

  // Value is required for the program to compile:
  int l3; // COMPLIANT
  sizeof(l3);

  int l4, // COMPLIANT
      l5; // NON-COMPLIANT
  l4;
}

// Struct fields are not objects:
struct s {
  int x; // COMPLIANT
};

// Declaration of type struct is an object:
struct s g5; // NON-COMPLIANT

// Struct fields are not objects:
union u {
  int x; // COMPLIANT
};

// Declaration of type union is an object:
union u g6; // NON-COMPLIANT

// Typedefs are not objects:
typedef int td1; // COMPLIANT

// Declaration of typedef type object:
td1 g7; // NON-COMPLIANT

// Function parameters are not objects:
void f3(int p) {} // COMPLIANT

// Function type parameters are not objects:
typedef int td2(int x); // COMPLIANT

// Macros that define unused vars tests:
#define ONLY_DEF_VAR(x) int x = 0;
void f4() {
  ONLY_DEF_VAR(l1); // COMPLIANT
  l1;
  ONLY_DEF_VAR(l2); // NON-COMPLIANT
}

// NON-COMPLIANT
#define ALSO_DEF_VAR(x)                                                        \
  int x = 0;                                                                   \
  while (1)                                                                    \
    ;
void f5() {
  ALSO_DEF_VAR(l1); // COMPLIANT
  ALSO_DEF_VAR(l2); // COMPLIANT
}

#define DEF_UNUSED_INNER_VAR()                                                 \
  {                                                                            \
    int _v = 0;                                                                \
    while (1)                                                                  \
      ;                                                                        \
  } // NON-COMPLIANT
void f6() {
  DEF_UNUSED_INNER_VAR(); // COMPLIANT
}

__attribute__((unused)) int g8 = 1; // NON-COMPLIANT
#define ONLY_DEF_ATTR_UNUSED_VAR(x) __attribute__((unused)) int x = 0;
void f7() {
  ONLY_DEF_ATTR_UNUSED_VAR(l1); // COMPLIANT
  l1;
  ONLY_DEF_ATTR_UNUSED_VAR(l2); // NON-COMPLIANT
}

// NON-COMPLIANT
#define ALSO_DEF_ATTR_UNUSED_VAR(x)                                            \
  __attribute__((unused)) int x = 0;                                           \
  while (1)                                                                    \
    ;
void f8() {
  ALSO_DEF_ATTR_UNUSED_VAR(l1); // COMPLIANT
  ALSO_DEF_ATTR_UNUSED_VAR(l2); // COMPLIANT
}

// NON-COMPLIANT
#define DEF_ATTR_UNUSED_INNER_VAR()                                            \
  {                                                                            \
    __attribute__((unused)) int _v = 0;                                        \
    while (1)                                                                  \
      ;                                                                        \
  }

void f9() {
  DEF_ATTR_UNUSED_INNER_VAR(); // COMPLIANT
}

// Const variable tests:
const int g9 = 1;  // COMPLIANT
const int g10 = 1; // NON-COMPLIANT

void f10() {
  g9;
  const int l1 = 1; // COMPLIANT
  const int l2 = 1; // NON-COMPLIANT
  l1;
}

// Side effects should not disable this rule:
void f11() {
  int l1 = 1;    // COMPLIANT
  int l2 = l1++; // COMPLIANT
  l2;
}