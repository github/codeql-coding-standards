int g1;                  // external linkage
extern int g2;           // external linkage from explicit specification
const int g3 = 0;        // internal linkage
extern const int g4 = 0; // internal linkage
static int g5;           // internal linkage

namespace ns1 { // named namespace as external linkage
int l1;         // inherits external linkage from enclosing namespace

void f1() {} // inherits external linkage from enclosing namespace

enum e1 { // inherits external linkage from enclosing namespace
  E1_1,   // inherits external linkage from enumeration
  E1_2    // inherits external linkage from enumeration
};

typedef enum {
  E2_1,
  E2_2 // inherits external linkage from enumeration
} e2;  // inherits external linkage from enclosing namespace

template <typename T>
void f2(T p1) {} // inherits external linkage from enclosing namespace

class C1 { // inherits external linkage from enclosing namespace
  int m1;
  static int m2; // inherits external linkage from class scope
  void m3() {}   // inherits external linkage from class scope

  enum e1 { E1_1 };         // inherits external linkage from class scope
  typedef enum { E2_1 } e2; // inherits external linkage from class scope

  class C2 { // inherits external linkage from class scope
    int m1;
    static int m2; // inherits external linkage from class scope
    void m3() {} // inherits external linkage from class scope
  }; // inherits external linkage from class scope

  typedef class {
    int m1;
    // static int m2 not allowed in anonymous class
    void m3() {} // inherits external linkage from class scope
  } C3; // inherits external linkage from class scope

  class {
    int m1;
    // static int m2 not allowed in unnamed class
    void m3() {} // inherits no linkage from class scope
  } m4; // anonymous class outside typedef has no linkage
};

typedef class { // inherits external linkage from enclosing namespace
  int m1;
  // static int m2 not allowed in anonymous class
  void m3() {} // inherits external linkage from class scope

  class C2 { // inherits external linkage from enclosing class scope
    int m1;
    // static int m2 not allowed in anonymous class
    void m3() {} // inherits external linkage from class scope
  };

  typedef class { // inherits external linkage from enclosing namespace
    int m1;
    // static int m2 not allowed in anonymous class
    void m3() {} // inherits external linkage from class scope
  } C3; // inherits external linkage from enclosing namespace

  class {
    int m1;
    // static int m2 not allowed in unnamed class
    void m3() {} // inherits no linkage from class scope
  } m4; // anonymous class outside typedef has no linkage
} C2;

template <typename T>
class C3 { // inherits external linkage from enclosing namespace
  T m1;
};
} // namespace ns1

namespace {     // unnamed namespace has internal linkage
namespace ns2 { // inherits internal linkage from unnamed namespace
int l1;         // inherits internal linkage from enclosing namespace

void f1() {} // inherits internal linkage from enclosing namespace

enum e1 { // inherits internal linkage from enclosing namespace
  E1_1,   // inherits internal linkage from enumeration
  E1_2    // inherits internal linkage from enumeration
};

typedef enum {
  E2_1,
  E2_2 // inherits internal linkage from enumeration
} e2;  // inherits internal linkage from enclosing namespace

template <typename T>
void f2(T p1) {} // inherits internal linkage from enclosing namespace

class C1 { // inherits internal linkage from enclosing namespace
  int m1;
  static int m2; // inherits internal linkage from class scope
  void m3() {}   // inherits internal linkage from class scope

  class C2 {
    int m1;
    static int m2; // inherits internal linkage from class scope
    void m3() {} // inherits internal linkage from class scope
  }; // inherits internal linkage from class scope

  typedef struct {
    int m1;
    // static int m2 not allowed in anonymous class
    void m3() {} // inherits internal linkage from class scope
  } C3; // inherits internal linkage from class scope

  class {
    int m1;
    // static int m2 not allowed in unnamed class
    void m3() {} // inherits no linkage from class scope
  } m4; // anonymous class outside typedef has no linkage
};

typedef class { // inherits internal linkage from enclosing namespace
  int m1;
  // static int m2 not allowed in anonymous class
  void m3() {} // inherits internal linkage from class scope

  class C2 {
    int m1;
    // static int m2 not allowed in anonymous class
    void m3() {} // inherits internal linkage from class scope
  }; // inherits internal linkage from class scope

  typedef class { // inherits internal linkage from enclosing namespace
    int m1;
    // static int m2 not allowed in anonymous class
    void m3() {} // inherits internal linkage from class scope
  } C3; // inherits internal linkage from enclosing namespace

  class {
    int m1;
    // static int m2 not allowed in unnamed class
    void m3() {} // inherits no linkage from class scope
  } m4; // anonymous class outside typedef has no linkage
} C2;

template <typename T>
class C3 { // inherits internal linkage from enclosing namespace
  T m1;
};
} // namespace ns2
} // namespace

// The following example is from N3797 and represent a block scope case that is
// not supported.
static void f();
static int i; // internal linkage from static storage duration in global scope
void g() {
  extern void f(); // internal linkage
  int i; // object with automatic storage duration and no linkage inherited from
         // block scope
  {
    extern int i; // object with static storage duration and external linkage
  }
}

void block_scope() {
  struct S { // No linkage, block scope
    int m1;
    void member() {} // No linkage, block scope
  };

  typedef struct { // No linkage, block scope
    int m1;
    void member() {} // No linkage, block scope
  } S2;
  
}