enum class COLOR { RED, BLUE } color; // NON_COMPLIANT

COLOR c1; // COMPLIANT

enum class COLOR1 { RED, BLUE } color1, color11; // NON_COMPLIANT (two counts)

COLOR1 c2; // COMPLIANT

enum class COLOR2 { RED, BLUE };

COLOR2 c3; // COMPLIANT

struct RGB {
  int r;
  int g;
  int b;
} rgb; // NON_COMPLIANT

RGB r1; // COMPLIANT

struct RGB1 {
  int r;
  int g;
  int b;
} rgb1, rgb11; // NON_COMPLIANT (2 counts)

RGB1 r2; // COMPLIANT

struct RGB2 {
  int r;
  int g;
  int b;
};

RGB2 r3; // COMPLIANT

class A {
public:
  enum class COLOR { RED, BLUE } color; // NON_COMPLIANT

  COLOR cc1; // COMPLIANT

  enum class COLOR1 { RED, BLUE } color1, color11; // NON_COMPLIANT (2 counts)

  COLOR1 cc2; // COMPLIANT

  enum class COLOR2 { RED, BLUE }; // COMPLIANT

  COLOR2 cc3; // COMPLIANT

  struct RGB {
    int r;
    int g;
    int b;
  } rgb; // NON_COMPLIANT

  RGB rr1; // COMPLIANT

  struct RGB1 {
    int r;
    int g;
    int b;
  } rgb1, rgb11; // NON_COMPLIANT (2 counts)

  RGB1 rr2; // COMPLIANT

  struct RGB2 {
    int r;
    int g;
    int b;
  };

  RGB2 rr3; // COMPLIANT
};

struct NS {
  bool operator==(NS) const { return true; }
  bool operator<(NS) const { return false; }
};

// clang-format off
struct A1 { }; A1 a; // COMPLIANT[FALSE_POSITIVE]
// clang-format on

struct s {
  int x;
#ifdef ADD_FOO
  int foo;
#endif
} s; // NON_COMPLIANT[FALSE_NEGATIVE]