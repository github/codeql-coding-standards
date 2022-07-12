class ClassA {
public:
  ClassA() { throw "Exception"; }

  ClassA(int i) noexcept {}

  ClassA(int i, int j) { throw "Exception"; }
};

ClassA safe_init() {
  ClassA a(1);
  return a;
}

ClassA bad_init() { throw "Exception"; }

int bad_calc(int x, int y) { throw "Exception"; }

static ClassA a1;                   // NON_COMPLIANT
static ClassA a2(1);                // COMPLIANT
static ClassA a3(1, 1);             // NON_COMPLIANT
static ClassA a4 = safe_init();     // COMPLIANT
static ClassA a5 = bad_init();      // NON_COMPLIANT
static int a6 = 1 + bad_calc(5, 3); // NON_COMPLIANT
