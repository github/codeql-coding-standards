class A { // NON_COMPLIANT
public:
  template <typename T> T &operator=(T const &rhs) {
    if (this != &rhs) {
      delete m;
      m = new int;
      *m = *rhs.m;
    }
  }

private:
  int *m;
};

class B { // COMPLIANT
public:
  B &operator=(B const &rhs) {
    if (this != &rhs) {
      delete m;
      m = new int;
      *m = *rhs.m;
    }
  }
  template <typename T> T &operator=(T const &rhs) {
    if (this != &rhs) {
      delete m;
      m = new int;
      *m = *rhs.m;
    }
  }

private:
  int *m;
};

class C { // COMPLIANT
public:
  // has generic parameter but looks like move operator not copy
  template <typename T> T &operator=(T const &&rhs) {
    if (this != &rhs) {
      delete m;
      m = new int;
      *m = *rhs.m;
    }
  }

private:
  int *m;
};

class D { // NON_COMPLIANT
public:
  D &operator=(D const &rhs) = delete;

  template <typename T> T &operator=(T const &rhs) {
    if (this != &rhs) {
      delete m;
      m = new int;
      *m = *rhs.m;
    }
  }

private:
  int *m;
};