class ClassA {
public:
  ClassA() { throw "Exception"; }

  ClassA(int i) noexcept {}

  ClassA(int i, int j) { throw "Exception"; }
};

static ClassA a1;       // NON_COMPLIANT
static ClassA a2(1);    // COMPLIANT
static ClassA a3(1, 1); // NON_COMPLIANT