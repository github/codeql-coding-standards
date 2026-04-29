struct A {
  int a;
  int &b;

  int &geta() & { return a; } // COMPLIANT

  int const &geta2() const & { // COMPLIANT  -- due to overload below
    return a;
  }
  int geta2() && { return a; }

  int const &getabad() const & { // NON_COMPLIANT  -- no overload provided
    return a;
  }

  int getb() && { return b; } // COMPLIANT -- b is not a subobject

  A const *getstruct() const & { // COMPLIANT  -- due to overload below
    return this;
  }

  A getstruct() const && = delete;

  A const *getstructbad() const & { // NON_COMPLIANT  -- no overload provided
    return this;
  }

  A &getstructbad2() { return *this; } // NON_COMPLIANT
};

class C {
  C *f() { // COMPLIANT -- this is not explicitly designated therefore this is
           // not
    // relevant for this rule
    C *thisclass = this;
    return thisclass;
  }
};

struct Templ {
  template <typename T>
  Templ const *f(T) const & { // NON_COMPLIANT -- for an instantiation below
    return this;
  }

  void f(int) const && = delete;
};

void f(int p, float p1) {
  Templ t;
  t.f(p);
  t.f(p1); // instantiation that causes issue due to parameter list type meaning
           // there is no overload
}

class B {
  int i;
  int *ip;
  int **ip2;

  int *f() {
    return &i; // NON_COMPLIANT
  }
  int *f1() {
    return ip; // COMPLIANT -- reads pointer
  }
  int *f2() {
    return *ip2; // COMPLIANT -- reads pointer
  }

  int **f3() {
    return &ip; // NON_COMPLIANT
  }

  int **f4() {
    return ip2; // COMPLIANT -- copies pointer
  }

  int &f5() {
    return i; // NON_COMPLIANT
  }
  int &f6() {
    return *ip; // COMPLIANT -- reads pointer
  }
  int &f7() {
    return **ip2; // COMPLIANT -- reads pointer
  }

  int *&f8() {
    // return &p; // won't compile
    return ip; // NON_COMPLIANT
  }
  int *&f9() {
    return *ip2; // COMPLIANT -- reads pointer
  }
};

class D {
  int i;
  int *ip;
  int **ip2;

  int *f() {
    return &(this->i); // NON_COMPLIANT
  }
  int *f1() {
    return this->ip; // COMPLIANT -- reads pointer
  }
  int *f2() {
    return *this->ip2; // COMPLIANT -- reads pointer
  }

  int **f3() {
    return &this->ip; // NON_COMPLIANT
  }

  int **f4() {
    return this->ip2; // COMPLIANT -- copies pointer
  }

  int &f5() {
    return this->i; // NON_COMPLIANT
  }
  int &f6() {
    return *this->ip; // COMPLIANT -- reads pointer
  }
  int &f7() {
    return **this->ip2; // COMPLIANT -- reads pointer
  }

  int *&f8() {
    // return &p; // won't compile
    return this->ip; // NON_COMPLIANT
  }
  int *&f9() {
    return *this->ip2; // COMPLIANT -- reads pointer
  }
};