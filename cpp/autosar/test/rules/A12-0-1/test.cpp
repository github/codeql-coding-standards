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

class C10 {
  ~C10() = default; // NON_COMPLIANT
};

class C11 {
  ~C11() = delete; // NON_COMPLIANT
};

class C12 {
  C12(C12 const &); // NON_COMPLIANT
};

class C13 {
  C13(C13 const &) = default; // NON_COMPLIANT
};

class C14 {
  C14(C14 const &) = delete; // NON_COMPLIANT
};

class C15 {
  C15 &operator=(C15 const &); // NON_COMPLIANT
};

template <typename T> class C16 { // COMPLIANT
  C16() = default;
};

template <typename T> class C17 { // COMPLIANT
  C17() = default;
  C17(C17 const &) = default;
  C17(C17 &&) = default;
  virtual ~C17() = default;
  C17 &operator=(C17 const &) = default;
  C17 &operator=(C17 &&) = default;
};

template <typename T> class C18 { // COMPLIANT
  C18() = default;
  C18(C18 const &) = delete;
  C18(C18 &&) = delete;
  virtual ~C18() = default;
  C18 &operator=(C18 const &) = delete;
  C18 &operator=(C18 &&) = delete;
};

template <typename T> class C19 { // COMPLIANT
public:
  explicit C19(T i) : i(i) {}
  C19(C19 const &) = delete;
  C19(C19 &&) = delete;
  virtual ~C19() = default;
  C19 &operator=(C19 const &) = delete;
  C19 &operator=(C19 &&) = delete;

private:
  T i;
};