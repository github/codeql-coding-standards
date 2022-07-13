class C1 {}; // COMPLIANT

class C2 { // COMPLIANT
  C2() = default;
  C2(C2 const &) = default;
  C2(C2 &&) = default;
  ~C2() {}
  C2 &operator=(C2 const &) = default;
  C2 &operator=(C2 &&) = default;
};

class C3 { // NON_COMPLIANT -  Missing a destructor
  C3() = default;
  C3(C3 const &) = default;
  C3(C3 &&) = default;
  C3 &operator=(C3 const &) = default;
  C3 &operator=(C3 &&) = default;
};
class C4 { // COMPLIANT
  C4() = default;
  C4(C4 const &) = default;
  C4(C4 &&) = default;
  ~C4() {}
  C4 &operator=(C4 const &) = delete;
  C4 &operator=(C4 &&) = default;
};

class C5 { // NON_COMPLIANT
  ~C5() {}
};

struct C6 { // COMPLIANT
  C6() = default;
};

struct C7 { // COMPLIANT
  C7() = delete;

  struct C8;
};

struct C7::C8 { // COMPLIANT
  C8() = delete;
};

struct C9 { // COMPLIANT
  C9() {}
  C9(int x) {}
};