typedef struct s {
  int i;
} s; // COMPLIANT

struct s1 { // NON_COMPLIANT
  int i;
};

struct s1 a1 = {0}; // COMPLIANT

void f() {
  struct s1 { // NON_COMPLIANT
    int i;
  };
}

void f1() { int s1 = 0; }

typedef struct {
  int i;
} sunnamed; // COMPLIANT

typedef struct {
  int i;
} sunnamed2; // COMPLIANT

typedef union {
  int i;
} U; // COMPLIANT

typedef union {
  int i;
}; // COMPLIANT